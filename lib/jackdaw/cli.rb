# frozen_string_literal: true

module Jackdaw
  # Main CLI entry point
  class CLI < Thor
    include CLIHelpers

    def self.exit_on_failure?
      true
    end

    desc 'build', 'Build the static site'
    method_option :clean, type: :boolean, aliases: '-c', desc: 'Clean output directory before building'
    method_option :watch, type: :boolean, aliases: '-w', desc: 'Watch for changes and rebuild'
    method_option :verbose, type: :boolean, aliases: '-v', desc: 'Verbose output'
    def build
      Commands::Build.new(Project.new, options).execute
    end

    desc 'serve', 'Start development server'
    method_option :port, type: :numeric, aliases: '-p', default: 4000, desc: 'Port to run server on'
    method_option :host, type: :string, aliases: '-h', default: 'localhost', desc: 'Host to bind to'
    method_option :livereload, type: :boolean, aliases: '-l', default: true, desc: 'Enable live reload'
    def serve
      Commands::Serve.new(Project.new, options).execute
    end

    desc 'create TEMPLATE NAME', 'Create a new content file from template'
    method_option :dated, type: :boolean, desc: 'Add date prefix to filename'
    method_option :no_date, type: :boolean, desc: 'Skip date prefix (overrides default behavior)'
    def create(template, name)
      Commands::Create.new(Project.new, template, name, options).execute
    end

    desc 'new NAME', 'Create a new site project'
    def new(name)
      Commands::New.new(name).execute
    end

    desc 'template SUBCOMMAND', 'Manage templates'
    subcommand 'template', Commands::Template

    desc 'version', 'Show version'
    def version
      puts "\n#{colorize('Jackdaw', :bold)} #{colorize("v#{Jackdaw::VERSION}", :cyan)}"
      puts colorize('Lightning-fast static site generator', :magenta)
    end
  end
end
