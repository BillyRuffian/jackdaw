# frozen_string_literal: true

module Jackdaw
  # Base class for all file types
  class BaseFile
    attr_reader :path, :project

    def initialize(path, project)
      @path = File.expand_path(path)
      @project = project
    end

    def basename
      File.basename(path)
    end

    def mtime
      File.mtime(path)
    end

    def relative_path
      path.sub("#{base_dir}/", '')
    end

    def base_dir
      raise NotImplementedError
    end
  end

  # Represents a content file (*.*.md)
  class ContentFile < BaseFile
    def base_dir
      project.src_dir
    end

    # Extract type from filename (e.g., "hello.blog.md" -> "blog")
    def type
      @type ||= begin
        parts = basename.split('.')
        parts[-2] if parts.length >= 3
      end
    end

    # Extract name from filename (e.g., "2026-01-06-hello.blog.md" -> "hello")
    def name
      @name ||= begin
        base = basename.sub(/\.#{type}\.md$/, '')
        # Remove date prefix if present
        base.sub(/^\d{4}-\d{2}-\d{2}-/, '')
      end
    end

    # Extract date from filename or fall back to mtime
    def date
      @date ||= if basename =~ /^(\d{4}-\d{2}-\d{2})-/
                  Date.parse(::Regexp.last_match(1))
                else
                  Date.parse(mtime.strftime('%Y-%m-%d'))
                end
    end

    # Slug for URL (e.g., "hello_world" or "2026-01-06-hello_world")
    def slug
      @slug ||= name.gsub('_', '-')
    end

    # Output path relative to public/
    def output_path
      dir = File.dirname(relative_path)
      filename = "#{name}.html"
      dir == '.' ? filename : File.join(dir, filename)
    end

    # Full output path
    def output_file
      File.join(project.output_dir, output_path)
    end

    # Read raw content
    def content
      @content ||= File.read(path)
    end

    # Extract title from first H1
    def title
      @title ||= begin
        match = content.match(/^#\s+(.+)$/)
        match ? match[1].strip : name.gsub(/[-_]/, ' ').capitalize
      end
    end

    # Extract excerpt (first paragraph or 150 words)
    def excerpt
      @excerpt ||= begin
        # Remove title (first H1)
        text = content.sub(/^#\s+.+$/, '').strip

        # Get first paragraph or first 150 words
        first_para = text.split("\n\n").first
        words = first_para.to_s.split[0...150]
        excerpt_text = words.join(' ')

        # Add ellipsis if truncated
        excerpt_text += '...' if words.length == 150
        excerpt_text
      end
    end

    # Calculate reading time (words per minute = 200)
    def reading_time
      @reading_time ||= begin
        word_count = content.split.length
        minutes = (word_count / 200.0).ceil
        [minutes, 1].max
      end
    end

    # Metadata hash
    def metadata
      {
        title: title,
        date: date,
        slug: slug,
        type: type,
        path: output_path,
        excerpt: excerpt,
        reading_time: reading_time
      }
    end
  end

  # Represents a template file (*.html.erb)
  class TemplateFile < BaseFile
    def base_dir
      project.templates_dir
    end

    # Extract template type (e.g., "blog.html.erb" -> "blog")
    def type
      @type ||= basename.sub(/\.html\.erb$/, '')
    end

    # Read template content
    def content
      @content ||= File.read(path)
    end
  end

  # Represents an asset file
  class AssetFile < BaseFile
    def base_dir
      project.assets_dir
    end

    # Output path relative to public/
    def output_path
      relative_path
    end

    # Full output path
    def output_file
      File.join(project.output_dir, output_path)
    end

    # Copy asset to output
    def copy!
      FileUtils.mkdir_p(File.dirname(output_file))
      FileUtils.cp(path, output_file)
    end
  end
end
