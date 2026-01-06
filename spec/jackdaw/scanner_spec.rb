# frozen_string_literal: true

RSpec.describe Jackdaw::Scanner do
  let(:site_dir) { create_test_site }
  let(:project) { Jackdaw::Project.new(site_dir) }
  let(:scanner) { described_class.new(project) }

  describe '#content_files' do
    it 'returns empty array when src directory is empty' do
      expect(scanner.content_files).to eq([])
    end

    it 'finds content files with double extensions' do
      create_content_file(site_dir, 'index.page.md', '# Home')
      create_content_file(site_dir, 'about.page.md', '# About')

      files = scanner.content_files
      expect(files.length).to eq(2)
      expect(files).to all(be_a(Jackdaw::ContentFile))
    end

    it 'finds nested content files' do
      create_content_file(site_dir, 'blog/post1.blog.md', '# Post 1')
      create_content_file(site_dir, 'blog/post2.blog.md', '# Post 2')
      create_content_file(site_dir, 'blog/2024/old-post.blog.md', '# Old')

      files = scanner.content_files
      expect(files.length).to eq(3)
    end

    it 'ignores files without double extension' do
      create_content_file(site_dir, 'README.md', '# README')
      create_content_file(site_dir, 'test.blog.md', '# Valid')

      files = scanner.content_files
      expect(files.length).to eq(1)
      expect(files.first.basename).to eq('test.blog.md')
    end

    it 'handles non-existent src directory gracefully' do
      FileUtils.rm_rf(project.src_dir)
      expect(scanner.content_files).to eq([])
    end
  end

  describe '#template_files' do
    it 'returns empty array when templates directory is empty' do
      expect(scanner.template_files).to eq([])
    end

    it 'finds template files' do
      create_template_file(site_dir, 'layout.html.erb', '<%= content %>')
      create_template_file(site_dir, 'page.html.erb', '<%= content %>')
      create_template_file(site_dir, 'blog.html.erb', '<%= content %>')

      files = scanner.template_files
      expect(files.length).to eq(3)
      expect(files).to all(be_a(Jackdaw::TemplateFile))
    end

    it 'finds partials' do
      create_template_file(site_dir, '_nav.html.erb', '<nav></nav>')
      create_template_file(site_dir, '_footer.html.erb', '<footer></footer>')

      files = scanner.template_files
      expect(files.length).to eq(2)
    end

    it 'handles non-existent templates directory gracefully' do
      FileUtils.rm_rf(project.templates_dir)
      expect(scanner.template_files).to eq([])
    end
  end

  describe '#asset_files' do
    it 'returns empty array when assets directory is empty' do
      expect(scanner.asset_files).to eq([])
    end

    it 'finds asset files' do
      create_asset_file(site_dir, 'style.css', 'body {}')
      create_asset_file(site_dir, 'script.js', 'console.log("hi")')

      files = scanner.asset_files
      expect(files.length).to eq(2)
      expect(files).to all(be_a(Jackdaw::AssetFile))
    end

    it 'finds nested asset files' do
      create_asset_file(site_dir, 'css/main.css', 'body {}')
      create_asset_file(site_dir, 'css/theme.css', 'h1 {}')
      create_asset_file(site_dir, 'images/logo.png', 'PNG')

      files = scanner.asset_files
      expect(files.length).to eq(3)
    end

    it 'excludes directories' do
      create_asset_file(site_dir, 'css/main.css', 'body {}')
      # Directory is created automatically by create_asset_file

      files = scanner.asset_files
      expect(files.all? { |f| File.file?(f.path) }).to be true
    end

    it 'handles non-existent assets directory gracefully' do
      FileUtils.rm_rf(project.assets_dir)
      expect(scanner.asset_files).to eq([])
    end
  end

  describe '#all_files' do
    it 'combines all file types' do
      create_content_file(site_dir, 'index.page.md', '# Home')
      create_template_file(site_dir, 'layout.html.erb', '<%= content %>')
      create_asset_file(site_dir, 'style.css', 'body {}')

      files = scanner.all_files
      expect(files.length).to eq(3)
      expect(files.map(&:class)).to contain_exactly(
        Jackdaw::ContentFile,
        Jackdaw::TemplateFile,
        Jackdaw::AssetFile
      )
    end

    it 'returns empty array when project is empty' do
      expect(scanner.all_files).to eq([])
    end
  end
end
