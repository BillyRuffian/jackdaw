# frozen_string_literal: true

module Jackdaw
  module Commands
    # Template subcommands
    class Template < Thor
      include CLIHelpers

      def self.exit_on_failure?
        true
      end

      desc 'list', 'List available templates'
      def list
        project = Project.new

        unless project.exists?
          puts colorize('✗ No site directory found. Run this command from a .site directory.', :yellow)
          exit 1
        end

        template_files = find_template_files(project)

        if template_files.empty?
          puts colorize('No templates found in site/templates/', :yellow)
          exit 0
        end

        display_templates(template_files)
        show_usage_examples
      end

      private

      def find_template_files(project)
        Dir.glob(File.join(project.templates_dir, '*.html.erb'))
           .map { |f| File.basename(f, '.html.erb') }
           .reject { |name| name == 'layout' || name.start_with?('_') }
           .sort
      end

      def display_templates(template_files)
        puts "\n#{colorize('Available templates:', :bold)}"
        template_files.each do |template|
          dated_types = %w[blog post article news]
          dated_indicator = dated_types.include?(template) ? colorize(' (dated)', :cyan) : ''
          puts "  #{colorize('→', :green)} #{colorize(template, :cyan)}#{dated_indicator}"
        end
      end

      def show_usage_examples
        puts "\n#{colorize('Usage:', :bold)}"
        puts '  jackdaw create <template> <name>'
        puts "\n#{colorize('Examples:', :bold)}"
        puts '  jackdaw create page "About Us"'
        puts '  jackdaw create blog "My First Post"'
      end
    end
  end
end
