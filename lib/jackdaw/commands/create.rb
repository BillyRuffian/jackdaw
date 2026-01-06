# frozen_string_literal: true

module Jackdaw
  module Commands
    # Create command implementation
    class Create
      include CLIHelpers

      DATED_TYPES = %w[blog post article news].freeze

      def initialize(project, template, name, options)
        @project = project
        @template = template
        @name = name
        @options = options
      end

      def execute
        unless @project.exists?
          puts colorize('✗ No site directory found. Run this command from a .site directory.', :yellow)
          exit 1
        end

        validate_template!
        create_content_file
      end

      private

      def validate_template!
        template_file = File.join(@project.templates_dir, "#{@template}.html.erb")
        return if File.exist?(template_file)

        puts colorize("✗ Template '#{@template}' not found", :yellow)
        puts "  Run #{colorize('jackdaw template list', :cyan)} to see available templates"
        exit 1
      end

      def create_content_file
        filename = build_filename
        output_path = build_output_path(filename)

        check_file_exists!(output_path)
        ensure_directory_exists!(output_path)
        write_content_file!(output_path)
        show_success_message(output_path)
      end

      def build_filename
        slug = generate_slug
        add_date_prefix? ? "#{date_prefix}-#{slug}.#{@template}.md" : "#{slug}.#{@template}.md"
      end

      def generate_slug
        path_parts = @name.split('/')
        @filename_part = path_parts.pop
        @subdir = path_parts.join('/')

        @filename_part.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      end

      def add_date_prefix?
        if @options[:no_date]
          false
        elsif @options[:dated]
          true
        else
          DATED_TYPES.include?(@template)
        end
      end

      def date_prefix
        Time.now.strftime('%Y-%m-%d')
      end

      def build_output_path(filename)
        output_dir = @subdir.empty? ? @project.src_dir : File.join(@project.src_dir, @subdir)
        File.join(output_dir, filename)
      end

      def check_file_exists!(output_path)
        return unless File.exist?(output_path)

        puts colorize("✗ File already exists: #{output_path}", :yellow)
        exit 1
      end

      def ensure_directory_exists!(output_path)
        FileUtils.mkdir_p(File.dirname(output_path))
      end

      def write_content_file!(output_path)
        title = @name.split('/').last
        content = <<~MARKDOWN
          # #{title}

          Your content goes here. Edit this file to create your #{@template}.
        MARKDOWN

        File.write(output_path, content)
      end

      def show_success_message(output_path)
        relative_path = output_path.sub("#{Dir.pwd}/", '')
        puts ''
        success("Created #{colorize(@template, :cyan)}: #{colorize(relative_path, :green)}")
        info("Edit: #{colorize(relative_path, :cyan)}")
      end
    end
  end
end
