# frozen_string_literal: true

module Jackdaw
  # Shared helper methods for CLI output formatting
  module CLIHelpers
    # ANSI color codes for beautiful output
    COLORS = {
      reset: "\e[0m",
      bold: "\e[1m",
      green: "\e[32m",
      cyan: "\e[36m",
      yellow: "\e[33m",
      magenta: "\e[35m",
      blue: "\e[34m"
    }.freeze

    def colorize(text, color)
      "#{COLORS[color]}#{text}#{COLORS[:reset]}"
    end

    def success(text)
      puts "#{colorize('✓', :green)} #{text}"
    end

    def info(text)
      puts "#{colorize('→', :cyan)} #{text}"
    end

    def header(text)
      puts "\n#{COLORS[:bold]}#{COLORS[:magenta]}#{text}#{COLORS[:reset]}"
    end
  end
end
