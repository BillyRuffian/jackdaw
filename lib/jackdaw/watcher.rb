# frozen_string_literal: true

module Jackdaw
  # Watches for file changes and triggers callbacks
  class Watcher
    attr_reader :project, :listener

    def initialize(project)
      @project = project
      @callbacks = []
    end

    # Register a callback to be called on file changes
    def on_change(&block)
      @callbacks << block
    end

    # Start watching
    def start
      @listener = Listen.to(project.site_dir) do |modified, added, removed|
        notify_callbacks(modified, added, removed)
      end

      listener.start
    end

    # Stop watching
    def stop
      listener&.stop
    end

    private

    def notify_callbacks(modified, added, removed)
      @callbacks.each do |callback|
        callback.call(modified: modified, added: added, removed: removed)
      end
    end
  end
end
