# frozen_string_literal: true

module Jackdaw
  # Scans directories and discovers content files
  class Scanner
    attr_reader :project

    def initialize(project)
      @project = project
    end

    # Scan for all content files in src/ directory
    def content_files
      return [] unless Dir.exist?(project.src_dir)

      Dir.glob(File.join(project.src_dir, '**', '*.*.md')).map do |path|
        ContentFile.new(path, project)
      end
    end

    # Scan for all template files in templates/ directory
    def template_files
      return [] unless Dir.exist?(project.templates_dir)

      Dir.glob(File.join(project.templates_dir, '*.html.erb')).map do |path|
        TemplateFile.new(path, project)
      end
    end

    # Scan for all asset files in assets/ directory
    def asset_files
      return [] unless Dir.exist?(project.assets_dir)

      Dir.glob(File.join(project.assets_dir, '**', '*')).reject { |p| File.directory?(p) }.map do |path|
        AssetFile.new(path, project)
      end
    end

    # Get all files
    def all_files
      content_files + template_files + asset_files
    end
  end
end
