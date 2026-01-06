#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'fileutils'
require_relative 'lib/jackdaw'

# Benchmark Jackdaw performance
class JackdawBenchmark
  BENCHMARK_DIR = 'benchmark-site.site'
  SIZES = {
    small: { pages: 10, blog_posts: 20 },
    medium: { pages: 50, blog_posts: 100 },
    large: { pages: 100, blog_posts: 500 }
  }.freeze

  def initialize(size: :medium)
    @size = size
    @config = SIZES[size]
    @project = Jackdaw::Project.new(BENCHMARK_DIR)
  end

  def run
    puts "\n#{colorize('🚀 Jackdaw Performance Benchmark', :bold, :magenta)}"
    puts colorize("Site size: #{@size} (#{@config[:pages]} pages, #{@config[:blog_posts]} blog posts)", :cyan)
    puts colorize('=' * 70, :cyan)

    cleanup
    create_test_site
    run_benchmarks
    cleanup

    puts "\n#{colorize('✓ Benchmark complete!', :green)}"
  end

  private

  def create_test_site
    print colorize('Creating test site...', :yellow)
    @project.create!
    create_templates
    create_content
    puts colorize(' Done!', :green)
  end

  def create_templates
    # Layout
    File.write(File.join(@project.templates_dir, 'layout.html.erb'), <<~ERB)
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= title %> - Benchmark Site</title>
        <style>
          body { max-width: 800px; margin: 0 auto; padding: 2rem; font-family: system-ui; line-height: 1.6; }
          nav { margin-bottom: 2rem; }
        </style>
      </head>
      <body>
        <%= content %>
      </body>
      </html>
    ERB

    # Page template
    File.write(File.join(@project.templates_dir, 'page.html.erb'), <<~ERB)
      <main>
        <%= content %>
      </main>
    ERB

    # Blog template
    File.write(File.join(@project.templates_dir, 'blog.html.erb'), <<~ERB)
      <article>
        <header>
          <h1><%= title %></h1>
          <time datetime="<%= date %>"><%= date.strftime('%B %d, %Y') %></time>
        </header>
        <%= content %>
      </article>
    ERB
  end

  def create_content
    # Create pages
    @config[:pages].times do |i|
      File.write(File.join(@project.src_dir, "page-#{i}.page.md"), generate_page_content(i))
    end

    # Create blog posts
    blog_dir = File.join(@project.src_dir, 'blog')
    FileUtils.mkdir_p(blog_dir)
    @config[:blog_posts].times do |i|
      date = Date.today - i
      File.write(File.join(blog_dir, "#{date}-post-#{i}.blog.md"), generate_blog_content(i))
    end
  end

  def generate_page_content(index)
    <<~MD
      # Page #{index}

      This is test page number #{index} for benchmarking Jackdaw performance.

      ## Section 1

      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

      ## Section 2

      Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

      ### Subsection

      Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

      ## Code Example

      ```ruby
      def hello_world
        puts "Hello from page #{index}!"
      end
      ```

      **Bold text** and *italic text* and `code snippets`.
    MD
  end

  def generate_blog_content(index)
    <<~MD
      # Blog Post #{index}

      This is test blog post number #{index} for benchmarking.

      ## Introduction

      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero.

      ## Main Content

      Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet.

      ```javascript
      function testFunction() {
        console.log('Test from post #{index}');
        return true;
      }
      ```

      ## Conclusion

      Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta.

      - List item 1
      - List item 2
      - List item 3
    MD
  end

  def run_benchmarks
    puts "\n#{colorize('Running benchmarks...', :bold)}\n"

    # Clean build
    clean_build_time = benchmark_build(clean: true)
    total_files = @config[:pages] + @config[:blog_posts]

    # Incremental build (no changes)
    incremental_build_time = benchmark_build(clean: false)

    # Incremental build (with change)
    modify_single_file
    incremental_change_time = benchmark_build(clean: false)

    # Results
    puts "\n#{colorize('Results:', :bold, :magenta)}"
    puts colorize('-' * 70, :cyan)

    puts "Total files:              #{colorize(total_files.to_s, :cyan)}"
    puts "Clean build time:         #{colorize(format('%.3f seconds', clean_build_time), :green)}"
    puts "  Files/second:           #{colorize(format('%.1f', total_files / clean_build_time), :cyan)}"
    puts "Incremental (no change):  #{colorize(format('%.3f seconds', incremental_build_time), :green)}"
    puts "  Files/second:           #{colorize(format('%.1f', total_files / incremental_build_time), :cyan)}"
    puts "Incremental (1 change):   #{colorize(format('%.3f seconds', incremental_change_time), :green)}"
    puts "  Speedup vs clean:       #{colorize(format('%.1fx', clean_build_time / incremental_change_time), :yellow)}"

    puts colorize('-' * 70, :cyan)
  end

  def benchmark_build(clean: false)
    builder = Jackdaw::Builder.new(@project, { clean: clean })

    time = Benchmark.realtime do
      builder.build
    end

    label = clean ? 'Clean build' : 'Incremental build'
    puts "  #{colorize(label, :yellow)}: #{colorize(format('%.3fs', time), :green)}"

    time
  end

  def modify_single_file
    # Touch one file to trigger incremental rebuild
    first_page = File.join(@project.src_dir, 'page-0.page.md')
    content = File.read(first_page)
    File.write(first_page, content + "\n\nUpdated content.")
  end

  def cleanup
    FileUtils.rm_rf(BENCHMARK_DIR) if Dir.exist?(BENCHMARK_DIR)
  end

  def colorize(text, *colors)
    codes = {
      reset: "\e[0m",
      bold: "\e[1m",
      green: "\e[32m",
      cyan: "\e[36m",
      yellow: "\e[33m",
      magenta: "\e[35m"
    }

    prefix = colors.map { |c| codes[c] }.join
    "#{prefix}#{text}#{codes[:reset]}"
  end
end

# Run benchmark
if __FILE__ == $PROGRAM_NAME
  size = ARGV[0]&.to_sym || :medium
  benchmark = JackdawBenchmark.new(size: size)
  benchmark.run
end
