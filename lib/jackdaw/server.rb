# frozen_string_literal: true

module Jackdaw
  # Development server with live reload
  class Server
    attr_reader :project, :builder, :watcher, :port, :host

    def initialize(project, options = {})
      @project = project
      @builder = Builder.new(project, {})
      @port = options[:port] || 4000
      @host = options[:host] || 'localhost'
      @livereload = options.fetch(:livereload, true)
      @rebuilding = false
      @clients = []
    end

    # Start the server
    def start
      # Initial build
      puts "\n#{colorize('🚀 Building site...', :magenta)}"
      stats = builder.build
      show_build_stats(stats)

      # Setup file watcher
      setup_watcher if @livereload

      # Start Puma
      puts "\n#{colorize("⚡️ Server running at #{colorize("http://#{host}:#{port}", :cyan)}", :bold)}"
      puts colorize('Press Ctrl+C to stop', :magenta)
      puts ''

      Rack::Handler::Puma.run(rack_app, Port: port, Host: host, Silent: true)
    end

    def livereload?
      @livereload
    end

    private

    def rack_app
      server = self
      Rack::Builder.new do
        use Rack::CommonLogger
        use LiveReloadMiddleware, server if server.livereload?
        run StaticFileServer.new(server.project)
      end
    end

    def setup_watcher
      @watcher = Watcher.new(project)

      @watcher.on_change do |changes|
        next if @rebuilding

        @rebuilding = true
        Thread.new do
          rebuild_site(changes)
        ensure
          @rebuilding = false
        end
      end

      @watcher.start
    end

    def rebuild_site(changes)
      changed_files = changes.values.flatten.length
      puts "\n#{colorize('🔄 Rebuilding...', :cyan)} (#{changed_files} files changed)"

      stats = builder.build
      show_build_stats(stats)

      notify_reload if @livereload
    end

    def show_build_stats(stats)
      if stats.success?
        puts "#{colorize('✓',
                         :green)} Built #{colorize(stats.files_built.to_s,
                                                   :cyan)} pages in #{colorize(format('%.2fs', stats.total_time),
                                                                               :cyan)}"
      else
        puts colorize("✗ Build failed with #{stats.errors.length} errors", :yellow)
        stats.errors.each { |e| puts "  #{colorize('→', :yellow)} #{e.message}" }
      end
    end

    def notify_reload
      # In a real implementation, this would notify WebSocket clients
      # For now, the LiveReloadMiddleware handles it with polling
    end

    def colorize(text, color)
      colors = {
        reset: "\e[0m",
        bold: "\e[1m",
        green: "\e[32m",
        cyan: "\e[36m",
        yellow: "\e[33m",
        magenta: "\e[35m"
      }
      "#{colors[color]}#{text}#{colors[:reset]}"
    end
  end

  # Static file server
  class StaticFileServer
    def initialize(project)
      @project = project
    end

    def call(env)
      path = Rack::Utils.unescape_path(env['PATH_INFO'])
      file_path = File.join(@project.output_dir, path)

      # Serve index.html for directories
      file_path = File.join(file_path, 'index.html') if path.end_with?('/') || File.directory?(file_path)

      # Add .html extension if file doesn't exist
      unless File.exist?(file_path)
        html_path = "#{file_path}.html"
        file_path = html_path if File.exist?(html_path)
      end

      if File.exist?(file_path) && File.file?(file_path)
        serve_file(file_path)
      else
        [404, { 'Content-Type' => 'text/html' }, ['<h1>404 Not Found</h1>']]
      end
    end

    private

    def serve_file(path)
      content = File.read(path)
      content_type = mime_type(path)

      [200, { 'Content-Type' => content_type, 'Content-Length' => content.bytesize.to_s }, [content]]
    end

    def mime_type(path)
      case File.extname(path)
      when '.html' then 'text/html'
      when '.css' then 'text/css'
      when '.js' then 'application/javascript'
      when '.json' then 'application/json'
      when '.png' then 'image/png'
      when '.jpg', '.jpeg' then 'image/jpeg'
      when '.gif' then 'image/gif'
      when '.svg' then 'image/svg+xml'
      else 'text/plain'
      end
    end
  end

  # Live reload middleware
  class LiveReloadMiddleware
    RELOAD_SCRIPT = <<~JS
      <script>
        (function() {
          let lastCheck = Date.now();
          setInterval(function() {
            fetch('/__jackdaw_reload_check')
              .then(r => r.json())
              .then(data => {
                if (data.lastBuild > lastCheck) {
                  console.log('Jackdaw: Reloading page...');
                  location.reload();
                }
                lastCheck = Date.now();
              })
              .catch(() => {});
          }, 1000);
        })();
      </script>
    JS

    def initialize(app, server)
      @app = app
      @server = server
      @last_build = Time.now
    end

    def call(env)
      # Handle reload check endpoint
      if env['PATH_INFO'] == '/__jackdaw_reload_check'
        return [
          200,
          { 'Content-Type' => 'application/json' },
          [JSON.generate({ lastBuild: @last_build.to_f })]
        ]
      end

      status, headers, response = @app.call(env)

      # Inject reload script into HTML responses
      if headers['Content-Type']&.include?('text/html')
        body = +'' # Unary plus makes it mutable
        response.each { |part| body << part }

        if body.include?('</body>')
          body = body.sub('</body>', "#{RELOAD_SCRIPT}</body>")
          @last_build = Time.now
          headers['Content-Length'] = body.bytesize.to_s
          response = [body]
        end
      end

      [status, headers, response]
    end
  end
end
