# frozen_string_literal: true

module Jackdaw
  # Generates sitemap.xml for SEO
  class SitemapGenerator
    attr_reader :project, :scanner

    def initialize(project)
      @project = project
      @scanner = Scanner.new(project)
    end

    # Generate sitemap.xml
    def generate
      urls = all_content_urls

      sitemap = <<~SITEMAP
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          #{urls.map { |url| url_entry(url) }.join("\n")}
        </urlset>
      SITEMAP

      File.write(File.join(project.output_dir, 'sitemap.xml'), sitemap)
    end

    private

    def all_content_urls
      scanner.content_files.map do |file|
        {
          path: file.output_path,
          date: file.date,
          type: file.type
        }
      end
    end

    def url_entry(url)
      priority = calculate_priority(url[:type], url[:path])
      changefreq = calculate_changefreq(url[:type])

      <<~ENTRY.strip
          <url>
            <loc>#{site_url}/#{url[:path]}</loc>
            <lastmod>#{url[:date].to_time.utc.iso8601}</lastmod>
            <changefreq>#{changefreq}</changefreq>
            <priority>#{priority}</priority>
          </url>
      ENTRY
    end

    def calculate_priority(type, path)
      return '1.0' if path == 'index.html'
      return '0.8' if type == 'page'
      return '0.6' if %w[blog post article news].include?(type)

      '0.5'
    end

    def calculate_changefreq(type)
      return 'daily' if %w[blog post article news].include?(type)
      return 'weekly' if type == 'page'

      'monthly'
    end

    def site_url
      ENV.fetch('SITE_URL', 'http://localhost:4000')
    end
  end
end
