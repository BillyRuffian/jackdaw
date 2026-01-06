# encoding: UTF-8
# frozen_string_literal: true

module Jackdaw
  module Commands
    # Build command implementation
    class Build
      include CLIHelpers

      def initialize(project, options)
        @project = project
        @options = options
      end

      def execute
        return handle_missing_project unless @project.exists?

        header('🚀 Building your site...')
        info('Cleaning output directory...') if @options[:clean]

        # Build
        builder = Builder.new(@project, @options)
        stats = builder.build

        # Show results
        puts ''
        display_results(stats)
      end

      private

      def handle_missing_project
        puts colorize('✗ No site directory found. Run this command from a .site directory.', :yellow)
        exit 1
      end

      def display_results(stats)
        if stats.success?
          show_success(stats)
        else
          show_errors(stats)
          exit 1
        end
      end

      def show_success(stats)
        success("Built #{colorize(stats.files_built.to_s,
                                  :cyan)} pages in #{colorize(format('%.2fs', stats.total_time), :cyan)}")

        info("Skipped #{stats.files_skipped} unchanged files") if stats.files_skipped.positive?
        info("Copied #{stats.assets_copied} assets") if stats.assets_copied.positive?

        return unless stats.assets_skipped.positive? && @options[:verbose]

        info("Skipped #{stats.assets_skipped} unchanged assets")
      end

      def show_errors(stats)
        puts colorize("✗ Build failed with #{stats.errors.length} errors:", :yellow)
        stats.errors.each do |error|
          puts "  #{colorize('→', :yellow)} #{error.message}"
          puts "    #{error.backtrace.first}" if @options[:verbose] && error.backtrace
        end
      end
    end
  end
end
