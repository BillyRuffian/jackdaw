# frozen_string_literal: true

RSpec.describe Jackdaw::Builder do
  let(:site_dir) { create_test_site }
  let(:project) { Jackdaw::Project.new(site_dir) }
  let(:builder) { described_class.new(project) }

  before do
    # Set up basic templates
    create_template_file(site_dir, 'page.html.erb', '<div class="page"><%= content %></div>')
    create_template_file(site_dir, 'blog.html.erb', '<article><%= content %></article>')
  end

  describe '#build' do
    it 'creates output directory if not exists' do
      FileUtils.rm_rf(project.output_dir)

      builder.build

      expect(Dir.exist?(project.output_dir)).to be true
    end

    it 'builds content files to HTML' do
      create_content_file(site_dir, 'index.page.md', '# Home')
      create_content_file(site_dir, 'about.page.md', '# About')

      builder.build

      expect(File.exist?(File.join(project.output_dir, 'index.html'))).to be true
      expect(File.exist?(File.join(project.output_dir, 'about.html'))).to be true
    end

    it 'preserves directory structure in output' do
      create_content_file(site_dir, 'blog/first.blog.md', '# First Post')
      create_content_file(site_dir, 'blog/second.blog.md', '# Second Post')

      builder.build

      expect(File.exist?(File.join(project.output_dir, 'blog/first.html'))).to be true
      expect(File.exist?(File.join(project.output_dir, 'blog/second.html'))).to be true
    end

    it 'copies asset files' do
      create_asset_file(site_dir, 'style.css', 'body {}')
      create_asset_file(site_dir, 'images/logo.png', 'PNG')

      builder.build

      expect(File.exist?(File.join(project.output_dir, 'style.css'))).to be true
      expect(File.exist?(File.join(project.output_dir, 'images/logo.png'))).to be true
    end

    it 'returns build statistics' do
      create_content_file(site_dir, 'index.page.md', '# Home')
      create_content_file(site_dir, 'about.page.md', '# About')

      stats = builder.build

      expect(stats).to be_a(Jackdaw::BuildStats)
      expect(stats.files_built).to eq(2)
      expect(stats.files_skipped).to eq(0)
      expect(stats.total_time).to be > 0
    end
  end

  describe '#clean_output' do
    it 'removes all files from output directory' do
      # Create some output files
      File.write(File.join(project.output_dir, 'old.html'), 'old content')
      File.write(File.join(project.output_dir, 'stale.html'), 'stale content')

      builder.clean_output

      expect(Dir.children(project.output_dir)).to be_empty
    end

    it 'handles non-existent output directory gracefully' do
      FileUtils.rm_rf(project.output_dir)

      expect { builder.clean_output }.not_to raise_error
    end
  end

  describe 'incremental builds' do
    it 'skips unchanged files on subsequent builds' do
      create_content_file(site_dir, 'index.page.md', '# Home')

      # First build
      stats1 = builder.build
      expect(stats1.files_built).to eq(1)

      # Second build without changes
      builder2 = described_class.new(project)
      stats2 = builder2.build
      expect(stats2.files_skipped).to eq(1)
      expect(stats2.files_built).to eq(0)
    end

    it 'rebuilds when content file changes' do
      path = create_content_file(site_dir, 'index.page.md', '# Home')

      # First build
      builder.build

      # Modify file
      sleep 0.01 # Ensure mtime changes
      File.write(path, '# Modified Home')

      # Second build
      builder2 = described_class.new(project)
      stats = builder2.build

      expect(stats.files_built).to eq(1)

      # Check content was updated
      output = File.read(File.join(project.output_dir, 'index.html'))
      expect(output).to include('Modified Home')
    end

    it 'rebuilds all when template changes' do
      create_content_file(site_dir, 'page1.page.md', '# Page 1')
      create_content_file(site_dir, 'page2.page.md', '# Page 2')

      # First build
      builder.build

      # Modify template
      template_path = File.join(project.templates_dir, 'page.html.erb')
      sleep 0.01
      File.write(template_path, '<div class="updated"><%= content %></div>')

      # Second build
      builder2 = described_class.new(project)
      stats = builder2.build

      expect(stats.files_built).to eq(2)

      # Check both files were rebuilt
      output1 = File.read(File.join(project.output_dir, 'page1.html'))
      output2 = File.read(File.join(project.output_dir, 'page2.html'))
      expect(output1).to include('class="updated"')
      expect(output2).to include('class="updated"')
    end
  end

  describe 'error handling' do
    it 'tracks missing template errors' do
      create_content_file(site_dir, 'post.article.md', '# Article')
      # No article.html.erb template

      stats = builder.build

      expect(stats.errors.length).to eq(1)
      expect(stats.errors.first.message).to include('Missing template')
    end

    it 'continues building other files after error' do
      create_content_file(site_dir, 'good.page.md', '# Good')
      create_content_file(site_dir, 'bad.missing.md', '# Bad')

      stats = builder.build

      expect(stats.files_built).to eq(1)
      expect(stats.errors.length).to eq(1)
      expect(File.exist?(File.join(project.output_dir, 'good.html'))).to be true
    end
  end

  describe 'with clean option' do
    it 'removes old files before building' do
      # Create old output file
      File.write(File.join(project.output_dir, 'old.html'), 'old')

      # Build with clean option
      builder_with_clean = described_class.new(project, clean: true)
      create_content_file(site_dir, 'new.page.md', '# New')
      builder_with_clean.build

      expect(File.exist?(File.join(project.output_dir, 'old.html'))).to be false
      expect(File.exist?(File.join(project.output_dir, 'new.html'))).to be true
    end
  end

  describe 'parallel processing' do
    it 'builds multiple files' do
      # Create multiple files
      10.times do |i|
        create_content_file(site_dir, "page#{i}.page.md", "# Page #{i}")
      end

      stats = builder.build

      expect(stats.files_built).to eq(10)

      # Verify all files exist
      10.times do |i|
        expect(File.exist?(File.join(project.output_dir, "page#{i}.html"))).to be true
      end
    end
  end
end

RSpec.describe Jackdaw::BuildStats do
  let(:stats) { described_class.new }

  describe '#initialize' do
    it 'initializes counters to zero' do
      expect(stats.files_built).to eq(0)
      expect(stats.files_skipped).to eq(0)
      expect(stats.assets_copied).to eq(0)
      expect(stats.errors).to eq([])
      expect(stats.total_time).to eq(0)
    end
  end

  describe '#total_files' do
    it 'sums built and skipped files' do
      stats.files_built = 5
      stats.files_skipped = 3

      expect(stats.total_files).to eq(8)
    end
  end

  describe '#success?' do
    it 'returns true when no errors' do
      stats.files_built = 5
      expect(stats.success?).to be true
    end

    it 'returns false when errors exist' do
      stats.errors << StandardError.new('Error')
      expect(stats.success?).to be false
    end
  end
end
