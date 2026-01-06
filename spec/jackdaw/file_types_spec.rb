# frozen_string_literal: true

RSpec.describe Jackdaw::ContentFile do
  let(:site_dir) { create_test_site }
  let(:project) { Jackdaw::Project.new(site_dir) }

  describe '#type' do
    it 'extracts type from double-extension filename' do
      path = create_content_file(site_dir, 'hello.blog.md', '# Hello')
      file = described_class.new(path, project)
      expect(file.type).to eq('blog')
    end

    it 'handles page type' do
      path = create_content_file(site_dir, 'about.page.md', '# About')
      file = described_class.new(path, project)
      expect(file.type).to eq('page')
    end
  end

  describe '#name' do
    it 'extracts name without date prefix' do
      path = create_content_file(site_dir, '2026-01-06-hello.blog.md', '# Hello')
      file = described_class.new(path, project)
      expect(file.name).to eq('hello')
    end

    it 'extracts name without date' do
      path = create_content_file(site_dir, 'about.page.md', '# About')
      file = described_class.new(path, project)
      expect(file.name).to eq('about')
    end

    it 'handles nested paths' do
      path = create_content_file(site_dir, 'blog/first-post.blog.md', '# Post')
      file = described_class.new(path, project)
      expect(file.name).to eq('first-post')
    end
  end

  describe '#date' do
    it 'parses date from filename' do
      path = create_content_file(site_dir, '2026-01-06-hello.blog.md', '# Hello')
      file = described_class.new(path, project)
      expect(file.date).to eq(Date.new(2026, 1, 6))
    end

    it 'falls back to mtime when no date in filename' do
      path = create_content_file(site_dir, 'about.page.md', '# About')
      file = described_class.new(path, project)
      expect(file.date).to be_a(Date)
    end
  end

  describe '#slug' do
    it 'converts underscores to hyphens' do
      path = create_content_file(site_dir, 'hello_world.blog.md', '# Hello')
      file = described_class.new(path, project)
      expect(file.slug).to eq('hello-world')
    end

    it 'preserves hyphens' do
      path = create_content_file(site_dir, 'first-post.blog.md', '# Post')
      file = described_class.new(path, project)
      expect(file.slug).to eq('first-post')
    end
  end

  describe '#output_path' do
    it 'generates HTML path for root file' do
      path = create_content_file(site_dir, 'index.page.md', '# Home')
      file = described_class.new(path, project)
      expect(file.output_path).to eq('index.html')
    end

    it 'preserves directory structure' do
      path = create_content_file(site_dir, 'blog/first-post.blog.md', '# Post')
      file = described_class.new(path, project)
      expect(file.output_path).to eq('blog/first-post.html')
    end

    it 'removes date prefix from output' do
      path = create_content_file(site_dir, '2026-01-06-hello.blog.md', '# Hello')
      file = described_class.new(path, project)
      expect(file.output_path).to eq('hello.html')
    end
  end

  describe '#content' do
    it 'reads file content' do
      content = "# Hello World\n\nThis is a test."
      path = create_content_file(site_dir, 'test.page.md', content)
      file = described_class.new(path, project)
      expect(file.content).to eq(content)
    end
  end

  describe '#relative_path' do
    it 'returns path relative to src directory' do
      path = create_content_file(site_dir, 'blog/post.blog.md', '# Post')
      file = described_class.new(path, project)
      expect(file.relative_path).to eq('blog/post.blog.md')
    end
  end
end

RSpec.describe Jackdaw::TemplateFile do
  let(:site_dir) { create_test_site }
  let(:project) { Jackdaw::Project.new(site_dir) }

  describe '#type' do
    it 'extracts type without .html.erb extension' do
      path = create_template_file(site_dir, 'blog.html.erb', '<%= content %>')
      file = described_class.new(path, project)
      expect(file.type).to eq('blog')
    end

    it 'handles layout template' do
      path = create_template_file(site_dir, 'layout.html.erb', '<%= content %>')
      file = described_class.new(path, project)
      expect(file.type).to eq('layout')
    end

    it 'handles partials' do
      path = create_template_file(site_dir, '_nav.html.erb', '<nav></nav>')
      file = described_class.new(path, project)
      expect(file.type).to eq('_nav')
    end
  end

  describe '#content' do
    it 'reads template content' do
      content = '<article><%= content %></article>'
      path = create_template_file(site_dir, 'post.html.erb', content)
      file = described_class.new(path, project)
      expect(file.content).to eq(content)
    end
  end

  describe '#relative_path' do
    it 'returns path relative to templates directory' do
      path = create_template_file(site_dir, 'blog.html.erb', '<%= content %>')
      file = described_class.new(path, project)
      expect(file.relative_path).to eq('blog.html.erb')
    end
  end
end

RSpec.describe Jackdaw::AssetFile do
  let(:site_dir) { create_test_site }
  let(:project) { Jackdaw::Project.new(site_dir) }

  describe '#output_path' do
    it 'preserves path structure' do
      path = create_asset_file(site_dir, 'css/style.css', 'body {}')
      file = described_class.new(path, project)
      expect(file.output_path).to eq('css/style.css')
    end

    it 'handles root-level assets' do
      path = create_asset_file(site_dir, 'logo.png', '')
      file = described_class.new(path, project)
      expect(file.output_path).to eq('logo.png')
    end
  end

  describe '#output_file' do
    it 'generates full output path' do
      path = create_asset_file(site_dir, 'style.css', 'body {}')
      file = described_class.new(path, project)
      expect(file.output_file).to eq(File.join(project.output_dir, 'style.css'))
    end
  end

  describe '#copy!' do
    it 'copies file to output directory' do
      content = 'body { color: red; }'
      path = create_asset_file(site_dir, 'style.css', content)
      file = described_class.new(path, project)

      file.copy!

      expect(File.exist?(file.output_file)).to be true
      expect(File.read(file.output_file)).to eq(content)
    end

    it 'creates necessary directories' do
      path = create_asset_file(site_dir, 'images/nested/logo.png', 'PNG_DATA')
      file = described_class.new(path, project)

      file.copy!

      expect(File.exist?(file.output_file)).to be true
    end
  end
end
