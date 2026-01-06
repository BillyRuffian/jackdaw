# frozen_string_literal: true

module Jackdaw
  module Commands
    # Serve command implementation
    class Serve
      include CLIHelpers

      def initialize(project, options)
        @project = project
        @options = options
      end

      def execute
        unless @project.exists?
          puts colorize('✗ No site directory found. Run this command from a .site directory.', :yellow)
          exit 1
        end

        server = Server.new(@project, @options)
        server.start
      rescue Interrupt
        puts "\n\n#{colorize('👋 Server stopped', :magenta)}"
        exit 0
      end
    end
  end
end
