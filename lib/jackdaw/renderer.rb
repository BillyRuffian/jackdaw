# frozen_string_literal: true

module Jackdaw
  # Renders content using ERB templates with layouts and partials
  class Renderer
    attr_reader :project, :scanner

    def initialize(project)
      @project = project
      @scanner = Scanner.new(project)
      @template_cache = {}
    end

    # Render a content file to HTML
    def render_content(content_file)
      # Get the template for this content type
      template = find_template(content_file.type)
      raise Error, "Template not found for type: #{content_file.type}" unless template

      # Build context
      context = build_context(content_file)

      # Render markdown to HTML
      html_content = render_markdown(content_file.content)

      # Render template with content
      template_html = render_template(template, context.merge(content: html_content))

      # Wrap in layout if it exists
      render_layout(template_html, context)
    end

    # Render a partial
    def render_partial(name, context = {})
      partial_path = File.join(project.templates_dir, "_#{name}.html.erb")
      raise Error, "Partial not found: #{name}" unless File.exist?(partial_path)

      template = load_template(partial_path)
      render_template(template, context)
    end

    private

    def find_template(type)
      template_path = File.join(project.templates_dir, "#{type}.html.erb")
      File.exist?(template_path) ? load_template(template_path) : nil
    end

    def load_template(path)
      # Cache compiled templates
      mtime = File.mtime(path)
      cache_key = "#{path}:#{mtime.to_i}"

      @template_cache[cache_key] ||= ERB.new(File.read(path), trim_mode: '-')
    end

    def render_template(template, context)
      binding_context = TemplateContext.new(context, self)
      template.result(binding_context.template_binding)
    end

    def render_markdown(markdown_content)
      Kramdown::Document.new(
        markdown_content,
        input: 'GFM',
        syntax_highlighter: 'rouge',
        syntax_highlighter_opts: {
          line_numbers: false,
          css_class: 'highlight'
        }
      ).to_html
    end

    def render_layout(content, context)
      layout_path = File.join(project.templates_dir, 'layout.html.erb')
      return content unless File.exist?(layout_path)

      layout = load_template(layout_path)
      render_template(layout, context.merge(content: content))
    end

    def build_context(content_file)
      {
        title: content_file.title,
        date: content_file.date,
        type: content_file.type,
        slug: content_file.slug,
        path: content_file.output_path,
        excerpt: content_file.excerpt,
        reading_time: content_file.reading_time,
        site_name: infer_site_name,
        all_posts: all_posts,
        all_pages: all_pages
      }
    end

    def infer_site_name
      # Extract site name from folder structure (e.g., "my-blog.site" -> "my-blog")
      project_name = File.basename(project.root)
      project_name.sub(/\.site$/, '').tr('-', ' ').split.map(&:capitalize).join(' ')
    end

    def all_posts
      @all_posts ||= scanner.content_files
                            .select { |f| %w[blog post].include?(f.type) }
                            .sort_by(&:date)
                            .reverse
    end

    def all_pages
      @all_pages ||= scanner.content_files
                            .select { |f| f.type == 'page' }
                            .sort_by(&:title)
    end
  end

  # Template context for ERB binding
  class TemplateContext
    include Jackdaw::SEOHelpers

    def initialize(context, renderer)
      @context = context
      @renderer = renderer

      # Make all context variables available as instance variables
      context.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Expose binding for ERB
    def template_binding
      binding
    end

    # Make context variables available as methods
    def method_missing(method_name, *args)
      if @context.key?(method_name)
        @context[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @context.key?(method_name) || super
    end

    # Render partial helper
    def render(partial_name, local_context = {})
      @renderer.render_partial(partial_name, @context.merge(local_context))
    end
  end
end
