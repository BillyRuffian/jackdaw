# frozen_string_literal: true

module Jackdaw
  #
  # Project structure management
  #
  # Defines the standard Jackdaw project structure and provides path helpers.
  # All Jackdaw projects follow this convention:
  #
  #   my-site.site/
  #   ├── site/
  #   │   ├── src/           # Content files (*.md)
  #   │   ├── templates/     # ERB templates (*.html.erb)
  #   │   └── assets/        # Static assets (images, CSS, JS)
  #   └── public/            # Generated output
  #
  # This convention-over-configuration approach eliminates the need for
  # configuration files while maintaining clear project organization.
  #
  class Project
    attr_reader :root

    # Initialize a project at the given root directory
    #
    # @param root [String] Path to project root (defaults to current directory)
    def initialize(root = Dir.pwd)
      @root = File.expand_path(root)
    end

    # Path to the site directory containing all source files
    #
    # @return [String] Absolute path to site/
    def site_dir
      File.join(root, 'site')
    end

    # Path to content source directory
    #
    # @return [String] Absolute path to site/src/
    def src_dir
      File.join(site_dir, 'src')
    end

    # Path to templates directory
    #
    # @return [String] Absolute path to site/templates/
    def templates_dir
      File.join(site_dir, 'templates')
    end

    # Path to assets directory
    #
    # @return [String] Absolute path to site/assets/
    def assets_dir
      File.join(site_dir, 'assets')
    end

    # Path to output directory for generated site
    #
    # @return [String] Absolute path to public/
    def output_dir
      File.join(root, 'public')
    end

    # Check if this is a valid Jackdaw project
    #
    # @return [Boolean] true if site/ directory exists
    def exists?
      Dir.exist?(site_dir)
    end

    # Create the standard project directory structure
    #
    # @return [void]
    def create!
      dirs = [site_dir, src_dir, templates_dir, assets_dir, output_dir]
      dirs.each { |dir| FileUtils.mkdir_p(dir) }
    end
  end
end
