# frozen_string_literal: true

module Jackdaw
  # Generates RSS and Atom feeds for blog posts
  class FeedGenerator
    attr_reader :project, :scanner

    def initialize(project)
      @project = project
      @scanner = Scanner.new(project)
    end

    # Generate RSS feed for blog posts
    def generate_rss
      posts = blog_posts.take(20) # Most recent 20 posts
      
      rss = <<~RSS
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
          <channel>
            <title>#{site_name}</title>
            <link>#{site_url}</link>
            <description>#{site_description}</description>
            <language>en</language>
            <atom:link href="#{site_url}/feed.xml" rel="self" type="application/rss+xml" />
            #{posts.map { |post| rss_item(post) }.join("\n")}
          </channel>
        </rss>
      RSS

      File.write(File.join(project.output_dir, 'feed.xml'), rss)
    end

    # Generate Atom feed for blog posts
    def generate_atom
      posts = blog_posts.take(20)
      updated = posts.first&.date&.to_time&.utc&.iso8601 || Time.now.utc.iso8601

      atom = <<~ATOM
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <title>#{site_name}</title>
          <link href="#{site_url}" />
          <link href="#{site_url}/atom.xml" rel="self" />
          <updated>#{updated}</updated>
          <id>#{site_url}/</id>
          <author>
            <name>#{site_name}</name>
          </author>
          #{posts.map { |post| atom_entry(post) }.join("\n")}
        </feed>
      ATOM

      File.write(File.join(project.output_dir, 'atom.xml'), atom)
    end

    private

    def blog_posts
      @blog_posts ||= scanner.content_files
                             .select { |f| %w[blog post article news].include?(f.type) }
                             .sort_by(&:date)
                             .reverse
    end

    def rss_item(post)
      <<~ITEM.strip
            <item>
              <title>#{escape_xml(post.title)}</title>
              <link>#{site_url}/#{post.output_path}</link>
              <guid>#{site_url}/#{post.output_path}</guid>
              <pubDate>#{post.date.to_time.utc.rfc822}</pubDate>
              <description>#{escape_xml(post.excerpt)}</description>
            </item>
      ITEM
    end

    def atom_entry(post)
      <<~ENTRY.strip
          <entry>
            <title>#{escape_xml(post.title)}</title>
            <link href="#{site_url}/#{post.output_path}" />
            <id>#{site_url}/#{post.output_path}</id>
            <updated>#{post.date.to_time.utc.iso8601}</updated>
            <summary>#{escape_xml(post.excerpt)}</summary>
          </entry>
      ENTRY
    end

    def site_name
      project_name = File.basename(project.root)
      project_name.sub(/\.site$/, '').tr('-', ' ').split.map(&:capitalize).join(' ')
    end

    def site_url
      # Default to localhost for development, can be overridden
      ENV.fetch('SITE_URL', 'http://localhost:4000')
    end

    def site_description
      "Latest posts from #{site_name}"
    end

    def escape_xml(text)
      text.to_s
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&apos;')
    end
  end
end
