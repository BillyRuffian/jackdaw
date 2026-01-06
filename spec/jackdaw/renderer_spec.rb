# frozen_string_literal: true

RSpec.describe Jackdaw::Renderer do
  let(:site_dir) { create_test_site }
  let(:project) { Jackdaw::Project.new(site_dir) }
  let(:renderer) { described_class.new(project) }

  describe '#render_markdown' do
    it 'converts markdown to HTML' do
      markdown = "# Hello\n\nThis is **bold** text."
      html = renderer.send(:render_markdown, markdown)

      expect(html).to include('<h1')
      expect(html).to include('Hello')
      expect(html).to include('<strong>bold</strong>')
    end

    it 'handles code blocks with syntax highlighting' do
      markdown = "```ruby\ndef hello\n  puts 'hi'\nend\n```"
      html = renderer.send(:render_markdown, markdown)

      expect(html).to include('highlight')
      expect(html).to include('hello')
      expect(html).to include('puts')
    end

    it 'handles GitHub Flavored Markdown' do
      markdown = "- [ ] Task\n- [x] Done"
      html = renderer.send(:render_markdown, markdown)

      expect(html).to include('type="checkbox"')
    end
  end

  describe '#render_content' do
    before do
      # Create a simple page template
      create_template_file(site_dir, 'page.html.erb', '<div class="page"><%= content %></div>')
    end

    it 'renders content with template' do
      content = "# Test Page\n\nSome content here."
      path = create_content_file(site_dir, 'test.page.md', content)
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('<div class="page">')
      expect(result).to include('<h1')
      expect(result).to include('Test Page')
      expect(result).to include('Some content here')
    end

    it 'wraps content in layout when layout exists' do
      create_template_file(site_dir, 'layout.html.erb',
                           '<html><body><%= content %></body></html>')

      content = '# Page'
      path = create_content_file(site_dir, 'test.page.md', content)
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('<html>')
      expect(result).to include('<div class="page">')
      expect(result).to include('Page')
      expect(result).to include('</html>')
    end

    it 'raises error when template not found' do
      content = '# Blog Post'
      path = create_content_file(site_dir, 'post.blog.md', content)
      content_file = Jackdaw::ContentFile.new(path, project)

      expect { renderer.render_content(content_file) }.to raise_error(Jackdaw::Error, /Template not found/)
    end

    it 'provides context variables to templates' do
      template = <<~ERB
        <article>
          <h1><%= title %></h1>
          <time><%= date %></time>
          <p>Reading time: <%= reading_time %> min</p>
          <%= content %>
        </article>
      ERB
      create_template_file(site_dir, 'page.html.erb', template)

      content = "# My Title\n\n#{'Word ' * 250}"
      path = create_content_file(site_dir, 'test.page.md', content)
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('<h1>My Title</h1>')
      expect(result).to include('<time>')
      expect(result).to include('Reading time:')
    end
  end

  describe '#render_partial' do
    it 'renders a partial' do
      create_template_file(site_dir, '_nav.html.erb', '<nav>Navigation</nav>')

      result = renderer.render_partial('nav')

      expect(result).to eq('<nav>Navigation</nav>')
    end

    it 'renders partial with context' do
      create_template_file(site_dir, '_greeting.html.erb', '<p>Hello, <%= name %>!</p>')

      result = renderer.render_partial('greeting', name: 'Alice')

      expect(result).to eq('<p>Hello, Alice!</p>')
    end

    it 'raises error when partial not found' do
      expect { renderer.render_partial('nonexistent') }.to raise_error(Jackdaw::Error, /Partial not found/)
    end
  end

  describe 'template caching' do
    it 'caches compiled templates' do
      create_template_file(site_dir, 'page.html.erb', '<%= content %>')

      path1 = create_content_file(site_dir, 'page1.page.md', '# Page 1')
      path2 = create_content_file(site_dir, 'page2.page.md', '# Page 2')

      file1 = Jackdaw::ContentFile.new(path1, project)
      file2 = Jackdaw::ContentFile.new(path2, project)

      # Render both pages
      renderer.render_content(file1)
      cache_size_after_first = renderer.instance_variable_get(:@template_cache).size

      renderer.render_content(file2)
      cache_size_after_second = renderer.instance_variable_get(:@template_cache).size

      # Cache should not grow since same template is reused
      expect(cache_size_after_first).to eq(cache_size_after_second)
    end
  end

  describe 'context building' do
    it 'provides all_posts to templates' do
      create_template_file(site_dir, 'page.html.erb',
                           '<% all_posts.each do |post| %><div><%= post.title %></div><% end %>')

      create_content_file(site_dir, '2026-01-01-first.blog.md', '# First Post')
      create_content_file(site_dir, '2026-01-02-second.blog.md', '# Second Post')

      path = create_content_file(site_dir, 'index.page.md', '# Home')
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('First Post')
      expect(result).to include('Second Post')
    end

    it 'provides all_pages to templates' do
      create_template_file(site_dir, 'page.html.erb',
                           '<% all_pages.each do |page| %><div><%= page.title %></div><% end %>')

      create_content_file(site_dir, 'about.page.md', '# About')
      create_content_file(site_dir, 'contact.page.md', '# Contact')

      path = create_content_file(site_dir, 'index.page.md', '# Home')
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('About')
      expect(result).to include('Contact')
      expect(result).to include('Home')
    end

    it 'provides site_name to templates' do
      create_template_file(site_dir, 'page.html.erb', '<title><%= site_name %></title>')

      path = create_content_file(site_dir, 'index.page.md', '# Home')
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('<title>Test Site</title>')
    end
  end

  describe 'render helper in templates' do
    it 'allows templates to render partials' do
      create_template_file(site_dir, '_header.html.erb', '<header>Site Header</header>')
      create_template_file(site_dir, 'page.html.erb',
                           '<%= render "header" %><main><%= content %></main>')

      path = create_content_file(site_dir, 'test.page.md', '# Test')
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('<header>Site Header</header>')
      expect(result).to include('<main>')
    end

    it 'passes context to rendered partials' do
      create_template_file(site_dir, '_title.html.erb', '<h1><%= title %></h1>')
      create_template_file(site_dir, 'page.html.erb',
                           '<%= render "title" %><div><%= content %></div>')

      path = create_content_file(site_dir, 'test.page.md', '# My Page')
      content_file = Jackdaw::ContentFile.new(path, project)

      result = renderer.render_content(content_file)

      expect(result).to include('<h1>My Page</h1>')
    end
  end
end

RSpec.describe Jackdaw::TemplateContext do
  let(:context) { { title: 'Test', count: 42 } }
  let(:renderer) { instance_double(Jackdaw::Renderer) }
  let(:template_context) { described_class.new(context, renderer) }

  describe '#method_missing' do
    it 'provides access to context values as methods' do
      expect(template_context.title).to eq('Test')
      expect(template_context.count).to eq(42)
    end

    it 'raises NoMethodError for undefined methods' do
      expect { template_context.undefined_method }.to raise_error(NoMethodError)
    end
  end

  describe '#respond_to_missing?' do
    it 'responds to context keys' do
      expect(template_context.respond_to?(:title)).to be true
      expect(template_context.respond_to?(:count)).to be true
    end

    it 'does not respond to undefined keys' do
      expect(template_context.respond_to?(:undefined)).to be false
    end
  end

  describe '#render' do
    it 'delegates to renderer' do
      allow(renderer).to receive(:render_partial).with('nav', context).and_return('<nav></nav>')

      result = template_context.render('nav')

      expect(result).to eq('<nav></nav>')
      expect(renderer).to have_received(:render_partial)
    end
  end
end
