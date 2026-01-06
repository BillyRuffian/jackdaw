# frozen_string_literal: true

module Jackdaw
  # Orchestrates the build process with incremental builds and parallel processing
  class Builder
    attr_reader :project, :scanner, :renderer, :stats

    def initialize(project, options = {})
      @project = project
      @scanner = Scanner.new(project)
      @renderer = Renderer.new(project)
      @options = options
      @stats = BuildStats.new
    end

    # Run full build
    def build
      start_time = Time.now

      # Clean if requested
      clean_output if @options[:clean]

      # Ensure output directory exists
      FileUtils.mkdir_p(project.output_dir)

      # Build content files in parallel
      build_content_files

      # Copy assets in parallel
      copy_assets

      # Generate feeds and sitemap
      generate_feeds_and_sitemap

      @stats.total_time = Time.now - start_time
      @stats
    end

    # Clean the output directory
    def clean_output
      return unless Dir.exist?(project.output_dir)

      FileUtils.rm_rf(Dir.glob(File.join(project.output_dir, '*')))
    end

    private

    def build_content_files
      content_files = scanner.content_files

      # Process files in parallel
      results = Parallel.map(content_files, in_threads: Parallel.processor_count) do |content_file|
        process_content_file(content_file)
      end

      # Aggregate results
      results.each do |result|
        case result[:status]
        when :built
          @stats.files_built += 1
        when :skipped
          @stats.files_skipped += 1
        when :error
          @stats.errors << result[:error]
        end
      end
    end

    def process_content_file(content_file)
      # Check if template exists
      template_file = File.join(project.templates_dir, "#{content_file.type}.html.erb")
      unless File.exist?(template_file)
        warning = "⚠️  Missing template '#{content_file.type}.html.erb' for #{content_file.path}"
        puts "\e[33m#{warning}\e[0m" if @options[:verbose]
        return { status: :error, file: content_file.path,
                 error: StandardError.new("Missing template: #{content_file.type}.html.erb") }
      end

      # Check if we need to rebuild
      return { status: :skipped, file: content_file.path } unless needs_rebuild?(content_file)

      # Render and write
      html = renderer.render_content(content_file)
      output_file = content_file.output_file

      FileUtils.mkdir_p(File.dirname(output_file))
      File.write(output_file, html)

      { status: :built, file: content_file.path }
    rescue StandardError => e
      { status: :error, file: content_file.path, error: e }
    end

    def copy_assets
      asset_files = scanner.asset_files

      results = Parallel.map(asset_files, in_threads: Parallel.processor_count) do |asset_file|
        next { status: :skipped } unless needs_asset_copy?(asset_file)

        asset_file.copy!
        { status: :copied }
      rescue StandardError => e
        { status: :error, error: e }
      end

      results.each do |result|
        case result[:status]
        when :copied
          @stats.assets_copied += 1
        when :skipped
          @stats.assets_skipped += 1
        when :error
          @stats.errors << result[:error]
        end
      end
    end

    def needs_rebuild?(content_file)
      # Always rebuild if clean build
      return true if @options[:clean]

      output_file = content_file.output_file

      # Rebuild if output doesn't exist
      return true unless File.exist?(output_file)

      output_mtime = File.mtime(output_file)

      # Check if content file is newer
      return true if content_file.mtime > output_mtime

      # Check if template is newer
      template_file = find_template_file(content_file.type)
      return true if template_file && File.mtime(template_file) > output_mtime

      # Check if layout is newer
      layout_file = File.join(project.templates_dir, 'layout.html.erb')
      return true if File.exist?(layout_file) && File.mtime(layout_file) > output_mtime

      false
    end

    def needs_asset_copy?(asset_file)
      # Always copy if clean build
      return true if @options[:clean]

      output_file = asset_file.output_file

      # Copy if output doesn't exist
      return true unless File.exist?(output_file)

      # Copy if source is newer
      asset_file.mtime > File.mtime(output_file)
    end

    def find_template_file(type)
      template_path = File.join(project.templates_dir, "#{type}.html.erb")
      File.exist?(template_path) ? template_path : nil
    end

    def generate_feeds_and_sitemap
      # Generate RSS/Atom feeds only if there are blog posts
      if has_blog_posts?
        feed_generator = FeedGenerator.new(project)
        feed_generator.generate_rss
        feed_generator.generate_atom
      end

      # Always generate sitemap
      sitemap_generator = SitemapGenerator.new(project)
      sitemap_generator.generate
    rescue StandardError => e
      puts "⚠️  Warning: Failed to generate feeds/sitemap: #{e.message}" if @options[:verbose]
    end

    def has_blog_posts?
      scanner.content_files.any? { |f| %w[blog post article news].include?(f.type) }
    end
  end

  # Tracks build statistics
  class BuildStats
    attr_accessor :files_built, :files_skipped, :assets_copied, :assets_skipped, :errors, :total_time

    def initialize
      @files_built = 0
      @files_skipped = 0
      @assets_copied = 0
      @assets_skipped = 0
      @errors = []
      @total_time = 0
    end

    def total_files
      files_built + files_skipped
    end

    def total_assets
      assets_copied + assets_skipped
    end

    def success?
      errors.empty?
    end
  end
end
