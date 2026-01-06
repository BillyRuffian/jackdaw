# frozen_string_literal: true

module Jackdaw
  module Commands
    # New command implementation for creating new site projects
    class New
      include CLIHelpers

      def initialize(name)
        @name = name
        @site_dir = name.end_with?('.site') ? name : "#{name}.site"
      end

      def execute
        check_directory_exists!

        header("✨ Creating new site: #{@name}")
        create_project_structure
        show_next_steps
      end

      private

      def check_directory_exists!
        return unless Dir.exist?(@site_dir)

        puts colorize("✗ Directory #{@site_dir} already exists", :yellow)
        exit 1
      end

      def create_project_structure
        info('Creating directory structure...')
        project = Project.new(@site_dir)
        project.create!

        create_starter_templates(project)
        create_example_content(project)
        create_gitignore(project)

        success("Site created at #{colorize(@site_dir, :cyan)}")
      end

      def create_starter_templates(project)
        create_layout_template(project)
        create_nav_partial(project)
        create_page_template(project)
        create_blog_template(project)

        success('Created starter templates')
      end

      def create_layout_template(project)
        layout_template = File.join(project.templates_dir, 'layout.html.erb')
        File.write(layout_template, <<~ERB)
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title><%= title %> - <%= site_name %></title>
            <style>
              body { max-width: 800px; margin: 0 auto; padding: 2rem; font-family: system-ui; line-height: 1.6; }
              nav { margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #ddd; }
              nav a { margin-right: 1rem; text-decoration: none; }
            </style>
          </head>
          <body>
            <%= render 'nav' %>
            <%= content %>
          </body>
          </html>
        ERB
      end

      def create_nav_partial(project)
        nav_partial = File.join(project.templates_dir, '_nav.html.erb')
        File.write(nav_partial, <<~ERB)
          <nav>
            <a href="/">Home</a>
            <a href="/blog">Blog</a>
          </nav>
        ERB
      end

      def create_page_template(project)
        page_template = File.join(project.templates_dir, 'page.html.erb')
        File.write(page_template, <<~ERB)
          <main>
            <%= content %>
          </main>
        ERB
      end

      def create_blog_template(project)
        blog_template = File.join(project.templates_dir, 'blog.html.erb')
        File.write(blog_template, <<~ERB)
          <article>
            <header>
              <h1><%= title %></h1>
              <time datetime="<%= date %>"><%= date.strftime('%B %d, %Y') %></time>
            </header>
            <%= content %>
          </article>
        ERB
      end

      def create_example_content(project)
        create_index_page(project)
        create_first_blog_post(project)

        success('Created example content')
      end

      def create_index_page(project)
        index_page = File.join(project.src_dir, 'index.page.md')
        File.write(index_page, <<~MD)
          # Welcome to Jackdaw

          This is your new static site, built with lightning-fast Jackdaw.

          ## Getting Started

          Edit this file at `site/src/index.page.md` and run `jackdaw build` to see your changes.
        MD
      end

      def create_first_blog_post(project)
        blog_dir = File.join(project.src_dir, 'blog')
        FileUtils.mkdir_p(blog_dir)

        first_post = File.join(blog_dir, '2026-01-06-hello-world.blog.md')
        File.write(first_post, <<~MD)
          # Hello World

          Welcome to your first blog post! This post demonstrates:

          - Automatic date extraction from filename
          - Title extraction from the first H1
          - Folder structure preservation

          Edit this file at `site/src/blog/2026-01-06-hello-world.blog.md`
        MD
      end

      def create_gitignore(project)
        gitignore = File.join(project.root, '.gitignore')
        File.write(gitignore, <<~IGNORE)
          public/
          .DS_Store
        IGNORE
        success('Created .gitignore')
      end

      def show_next_steps
        puts "\n#{colorize('Next steps:', :bold)}"
        info("cd #{@site_dir}")
        info('jackdaw build')
        info('jackdaw serve')
      end
    end
  end
end
