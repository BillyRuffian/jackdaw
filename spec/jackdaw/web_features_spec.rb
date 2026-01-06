# frozen_string_literal: true

RSpec.describe Jackdaw::FeedGenerator do
  let(:site_dir) { create_test_site(name: 'feed-test') }
  let(:project) { Jackdaw::Project.new(site_dir) }
  let(:generator) { described_class.new(project) }

  before do
    # Create blog posts
    create_content_file(site_dir, '2026-01-01-first.blog.md', "# First Post\n\nFirst post content.")
    create_content_file(site_dir, '2026-01-02-second.blog.md', "# Second Post\n\nSecond post content.")
  end

  describe '#generate_rss' do
    it 'generates valid RSS feed' do
      generator.generate_rss

      feed_path = File.join(project.output_dir, 'feed.xml')
      expect(File.exist?(feed_path)).to be true

      xml = File.read(feed_path)
      expect(xml).to include('<?xml version="1.0"')
      expect(xml).to include('<rss version="2.0"')
      expect(xml).to include('Feed Test')
      expect(xml).to include('First Post')
      expect(xml).to include('Second Post')
    end

    it 'includes proper RSS structure' do
      generator.generate_rss

      xml = File.read(File.join(project.output_dir, 'feed.xml'))
      expect(xml).to include('<channel>')
      expect(xml).to include('<item>')
      expect(xml).to include('<title>')
      expect(xml).to include('<link>')
      expect(xml).to include('<guid>')
      expect(xml).to include('<pubDate>')
    end

    it 'limits to most recent 20 posts' do
      # Create 25 posts
      25.times do |i|
        date = Date.new(2026, 1, i + 1)
        create_content_file(site_dir, "#{date}-post-#{i}.blog.md", "# Post #{i}")
      end

      generator.generate_rss

      xml = File.read(File.join(project.output_dir, 'feed.xml'))
      item_count = xml.scan(/<item>/).length
      expect(item_count).to eq(20)
    end
  end

  describe '#generate_atom' do
    it 'generates valid Atom feed' do
      generator.generate_atom

      feed_path = File.join(project.output_dir, 'atom.xml')
      expect(File.exist?(feed_path)).to be true

      xml = File.read(feed_path)
      expect(xml).to include('<?xml version="1.0"')
      expect(xml).to include('<feed xmlns="http://www.w3.org/2005/Atom"')
      expect(xml).to include('Feed Test')
      expect(xml).to include('First Post')
      expect(xml).to include('Second Post')
    end

    it 'includes proper Atom structure' do
      generator.generate_atom

      xml = File.read(File.join(project.output_dir, 'atom.xml'))
      expect(xml).to include('<entry>')
      expect(xml).to include('<title>')
      expect(xml).to include('<link')
      expect(xml).to include('<id>')
      expect(xml).to include('<updated>')
    end
  end
end

RSpec.describe Jackdaw::SitemapGenerator do
  let(:site_dir) { create_test_site(name: 'sitemap-test') }
  let(:project) { Jackdaw::Project.new(site_dir) }
  let(:generator) { described_class.new(project) }

  before do
    create_content_file(site_dir, 'index.page.md', '# Home')
    create_content_file(site_dir, 'about.page.md', '# About')
    create_content_file(site_dir, '2026-01-01-post.blog.md', '# Blog Post')
  end

  describe '#generate' do
    it 'generates valid sitemap.xml' do
      generator.generate

      sitemap_path = File.join(project.output_dir, 'sitemap.xml')
      expect(File.exist?(sitemap_path)).to be true

      xml = File.read(sitemap_path)
      expect(xml).to include('<?xml version="1.0"')
      expect(xml).to include('<urlset')
      expect(xml).to include('http://www.sitemaps.org')
    end

    it 'includes all pages' do
      generator.generate

      xml = File.read(File.join(project.output_dir, 'sitemap.xml'))
      expect(xml).to include('index.html')
      expect(xml).to include('about.html')
      expect(xml).to include('post.html')
    end

    it 'includes proper sitemap structure' do
      generator.generate

      xml = File.read(File.join(project.output_dir, 'sitemap.xml'))
      expect(xml).to include('<url>')
      expect(xml).to include('<loc>')
      expect(xml).to include('<lastmod>')
      expect(xml).to include('<changefreq>')
      expect(xml).to include('<priority>')
    end

    it 'prioritizes index page' do
      generator.generate

      xml = File.read(File.join(project.output_dir, 'sitemap.xml'))
      # Index should have priority 1.0
      expect(xml).to match(/index\.html.*<priority>1\.0<\/priority>/m)
    end
  end
end

RSpec.describe Jackdaw::SEOHelpers do
  let(:helper_class) do
    Class.new do
      include Jackdaw::SEOHelpers
    end
  end
  let(:helper) { helper_class.new }

  describe '#og_tags' do
    it 'generates Open Graph tags' do
      tags = helper.og_tags(
        title: 'My Page',
        description: 'Page description',
        url: 'https://example.com/page'
      )

      expect(tags).to include('property="og:title"')
      expect(tags).to include('My Page')
      expect(tags).to include('property="og:description"')
      expect(tags).to include('Page description')
      expect(tags).to include('property="og:url"')
      expect(tags).to include('https://example.com/page')
    end

    it 'includes image when provided' do
      tags = helper.og_tags(
        title: 'Title',
        description: 'Desc',
        url: 'https://example.com',
        image: 'https://example.com/image.jpg'
      )

      expect(tags).to include('property="og:image"')
      expect(tags).to include('https://example.com/image.jpg')
    end

    it 'escapes HTML entities' do
      tags = helper.og_tags(
        title: 'Title with <tags>',
        description: 'Desc & more',
        url: 'https://example.com'
      )

      expect(tags).to include('&lt;tags&gt;')
      expect(tags).to include('&amp;')
    end
  end

  describe '#twitter_tags' do
    it 'generates Twitter Card tags' do
      tags = helper.twitter_tags(
        title: 'Tweet Title',
        description: 'Tweet description'
      )

      expect(tags).to include('name="twitter:card"')
      expect(tags).to include('name="twitter:title"')
      expect(tags).to include('Tweet Title')
      expect(tags).to include('name="twitter:description"')
    end

    it 'includes optional fields when provided' do
      tags = helper.twitter_tags(
        title: 'Title',
        description: 'Desc',
        site: '@example',
        creator: '@author'
      )

      expect(tags).to include('name="twitter:site"')
      expect(tags).to include('@example')
      expect(tags).to include('name="twitter:creator"')
      expect(tags).to include('@author')
    end
  end

  describe '#canonical_tag' do
    it 'generates canonical link tag' do
      tag = helper.canonical_tag('https://example.com/page')

      expect(tag).to include('rel="canonical"')
      expect(tag).to include('href="https://example.com/page"')
    end
  end

  describe '#meta_description' do
    it 'generates meta description tag' do
      tag = helper.meta_description('This is a description')

      expect(tag).to include('name="description"')
      expect(tag).to include('This is a description')
    end
  end

  describe '#seo_tags' do
    it 'generates all SEO tags at once' do
      tags = helper.seo_tags(
        title: 'Page Title',
        description: 'Page description',
        url: 'https://example.com/page'
      )

      expect(tags).to include('name="description"')
      expect(tags).to include('rel="canonical"')
      expect(tags).to include('property="og:title"')
      expect(tags).to include('name="twitter:card"')
    end
  end
end
