# frozen_string_literal: true

RSpec.describe 'End-to-end build workflow' do
  let(:site_dir) { create_test_site(name: 'e2e-test') }
  let(:project) { Jackdaw::Project.new(site_dir) }

  def setup_complete_site
    # Create layout
    create_template_file(site_dir, 'layout.html.erb', <<~HTML)
      <!DOCTYPE html>
      <html>
      <head><title><%= title %> - <%= site_name %></title></head>
      <body>
        <%= render 'nav' %>
        <%= content %>
      </body>
      </html>
    HTML

    # Create partial
    create_template_file(site_dir, '_nav.html.erb', '<nav><a href="/">Home</a></nav>')

    # Create page template
    create_template_file(site_dir, 'page.html.erb', '<main><%= content %></main>')

    # Create blog template
    create_template_file(site_dir, 'blog.html.erb', <<~HTML)
      <article>
        <h1><%= title %></h1>
        <time><%= date.strftime('%B %d, %Y') %></time>
        <div class="reading-time"><%= reading_time %> min read</div>
        <%= content %>
      </article>
    HTML

    # Create content
    create_content_file(site_dir, 'index.page.md', <<~MD)
      # Welcome

      This is the homepage.
    MD

    create_content_file(site_dir, 'about.page.md', <<~MD)
      # About Us

      Learn more about us.
    MD

    create_content_file(site_dir, '2026-01-01-first-post.blog.md', <<~MD)
      # First Blog Post

      This is my first post with **bold** text and `code`.

      ```ruby
      def hello
        puts "Hello World"
      end
      ```
    MD

    create_content_file(site_dir, 'blog/2026-01-02-second-post.blog.md', <<~MD)
      # Second Post

      Another great post.
    MD

    # Create assets
    create_asset_file(site_dir, 'style.css', 'body { margin: 0; }')
    create_asset_file(site_dir, 'images/logo.png', 'FAKE_PNG_DATA')
  end

  describe 'complete site build' do
    it 'builds entire site successfully' do
      setup_complete_site

      builder = Jackdaw::Builder.new(project)
      stats = builder.build

      expect(stats.success?).to be true
      expect(stats.files_built).to eq(4) # 2 pages + 2 blog posts
      expect(stats.assets_copied).to eq(2) # style.css + logo.png
      expect(stats.errors).to be_empty
    end

    it 'generates valid HTML with layout' do
      setup_complete_site

      builder = Jackdaw::Builder.new(project)
      builder.build

      html = File.read(File.join(project.output_dir, 'index.html'))

      expect(html).to include('<!DOCTYPE html>')
      expect(html).to include('<html>')
      expect(html).to include('<title>Welcome - E2e Test</title>')
      expect(html).to include('<nav><a href="/">Home</a></nav>')
      expect(html).to include('<main>')
      expect(html).to include('This is the homepage')
    end

    it 'renders markdown with formatting' do
      setup_complete_site

      builder = Jackdaw::Builder.new(project)
      builder.build

      html = File.read(File.join(project.output_dir, 'first-post.html'))

      expect(html).to include('<strong>bold</strong>')
      expect(html).to include('<code>code</code>')
      expect(html).to include('highlight') # syntax highlighting
    end

    it 'includes blog post metadata' do
      setup_complete_site

      builder = Jackdaw::Builder.new(project)
      builder.build

      html = File.read(File.join(project.output_dir, 'first-post.html'))

      expect(html).to include('<h1>First Blog Post</h1>')
      expect(html).to include('January 01, 2026')
      expect(html).to include('min read')
    end

    it 'preserves nested directory structure' do
      setup_complete_site

      builder = Jackdaw::Builder.new(project)
      builder.build

      expect(File.exist?(File.join(project.output_dir, 'blog/second-post.html'))).to be true

      html = File.read(File.join(project.output_dir, 'blog/second-post.html'))
      expect(html).to include('Second Post')
    end

    it 'copies assets with directory structure' do
      setup_complete_site

      builder = Jackdaw::Builder.new(project)
      builder.build

      expect(File.exist?(File.join(project.output_dir, 'style.css'))).to be true
      expect(File.exist?(File.join(project.output_dir, 'images/logo.png'))).to be true

      css = File.read(File.join(project.output_dir, 'style.css'))
      expect(css).to eq('body { margin: 0; }')
    end
  end

  describe 'incremental build workflow' do
    it 'performs fast incremental builds' do
      setup_complete_site

      # First build
      builder1 = Jackdaw::Builder.new(project)
      stats1 = builder1.build
      expect(stats1.files_built).to eq(4)

      # Second build - nothing changed
      builder2 = Jackdaw::Builder.new(project)
      stats2 = builder2.build
      expect(stats2.files_skipped).to eq(4)
      expect(stats2.files_built).to eq(0)

      # Modify one file
      path = create_content_file(site_dir, 'about.page.md', '# Updated About')

      # Third build - only one file rebuilt
      builder3 = Jackdaw::Builder.new(project)
      stats3 = builder3.build
      expect(stats3.files_built).to eq(1)
      expect(stats3.files_skipped).to eq(3)
    end
  end

  describe 'clean build workflow' do
    it 'removes old files before building' do
      setup_complete_site

      # First build
      builder1 = Jackdaw::Builder.new(project)
      builder1.build

      # Create a stale file
      File.write(File.join(project.output_dir, 'stale.html'), 'old')

      # Clean build
      builder2 = Jackdaw::Builder.new(project, clean: true)
      builder2.build

      expect(File.exist?(File.join(project.output_dir, 'stale.html'))).to be false
      expect(File.exist?(File.join(project.output_dir, 'index.html'))).to be true
    end
  end

  describe 'error recovery' do
    it 'handles missing templates gracefully' do
      create_template_file(site_dir, 'page.html.erb', '<%= content %>')
      create_content_file(site_dir, 'good.page.md', '# Good')
      create_content_file(site_dir, 'bad.article.md', '# Bad') # No article template

      builder = Jackdaw::Builder.new(project)
      stats = builder.build

      expect(stats.success?).to be false
      expect(stats.files_built).to eq(1)
      expect(stats.errors.length).to eq(1)
      expect(File.exist?(File.join(project.output_dir, 'good.html'))).to be true
    end
  end

  describe 'site with many files' do
    it 'handles large site efficiently' do
      # Create templates
      create_template_file(site_dir, 'page.html.erb', '<%= content %>')

      # Create 50 pages
      50.times do |i|
        create_content_file(site_dir, "page-#{i}.page.md", "# Page #{i}\n\nContent for page #{i}")
      end

      builder = Jackdaw::Builder.new(project)
      stats = builder.build

      expect(stats.files_built).to eq(50)
      expect(stats.success?).to be true
      expect(stats.total_time).to be < 5 # Should build in under 5 seconds

      # Verify some files
      expect(File.exist?(File.join(project.output_dir, 'page-0.html'))).to be true
      expect(File.exist?(File.join(project.output_dir, 'page-49.html'))).to be true
    end
  end

  describe 'RSS/Atom feeds and sitemap' do
    it 'generates feeds and sitemap for sites with blog posts' do
      setup_complete_site
      
      builder = Jackdaw::Builder.new(project)
      builder.build

      # Check RSS feed
      expect(File.exist?(File.join(project.output_dir, 'feed.xml'))).to be true
      rss = File.read(File.join(project.output_dir, 'feed.xml'))
      expect(rss).to include('<rss version="2.0"')
      expect(rss).to include('First Blog Post')

      # Check Atom feed
      expect(File.exist?(File.join(project.output_dir, 'atom.xml'))).to be true
      atom = File.read(File.join(project.output_dir, 'atom.xml'))
      expect(atom).to include('<feed xmlns="http://www.w3.org/2005/Atom"')
      expect(atom).to include('Second Post')

      # Check sitemap
      expect(File.exist?(File.join(project.output_dir, 'sitemap.xml'))).to be true
      sitemap = File.read(File.join(project.output_dir, 'sitemap.xml'))
      expect(sitemap).to include('<urlset')
      expect(sitemap).to include('index.html')
      expect(sitemap).to include('about.html')
    end

    it 'skips feed generation for sites without blog posts' do
      create_template_file(site_dir, 'page.html.erb', '<%= content %>')
      create_content_file(site_dir, 'index.page.md', '# Home')
      create_content_file(site_dir, 'about.page.md', '# About')

      builder = Jackdaw::Builder.new(project)
      builder.build

      # Should not generate feeds without blog posts
      expect(File.exist?(File.join(project.output_dir, 'feed.xml'))).to be false
      expect(File.exist?(File.join(project.output_dir, 'atom.xml'))).to be false
      
      # But should still generate sitemap
      expect(File.exist?(File.join(project.output_dir, 'sitemap.xml'))).to be true
    end
  end
end
