# frozen_string_literal: true

#
# Jackdaw - Lightning-fast Ruby static site generator
#
# This is the main entry point for the Jackdaw gem. It loads all dependencies
# and internal modules in the correct order to ensure proper initialization.
#
# Philosophy:
# - Convention over configuration
# - Speed through parallel processing and incremental builds
# - Simplicity in structure and usage
#

# External dependencies
require 'fileutils' # File system operations
require 'date'      # Date parsing for blog posts
require 'time'      # Time formatting for feeds
require 'erb'       # Template engine
require 'json'      # JSON support for server
require 'listen'    # File watching for development server
require 'kramdown'  # Markdown parser
require 'kramdown-parser-gfm' # GitHub Flavored Markdown support
require 'rouge'     # Syntax highlighting
require 'parallel'  # Multi-threaded processing
require 'rack'      # Web server framework
require 'rack/handler/puma' # Puma server adapter
require 'thor' # CLI framework

# Internal requires - order matters for dependencies
require_relative 'jackdaw/version'
require_relative 'jackdaw/project'        # Project structure management
require_relative 'jackdaw/file_types'     # Content, Template, and Asset file abstractions
require_relative 'jackdaw/scanner'        # Directory scanning
require_relative 'jackdaw/seo_helpers'    # SEO meta tag helpers (must be before renderer)
require_relative 'jackdaw/renderer'       # ERB and Markdown rendering
require_relative 'jackdaw/feed_generator' # RSS/Atom feed generation
require_relative 'jackdaw/sitemap_generator' # Sitemap.xml generation
require_relative 'jackdaw/builder'        # Build orchestration
require_relative 'jackdaw/watcher'        # File watching
require_relative 'jackdaw/server'         # Development server
require_relative 'jackdaw/cli_helpers'    # Shared CLI utilities
require_relative 'jackdaw/commands/build' # Build command
require_relative 'jackdaw/commands/serve' # Serve command
require_relative 'jackdaw/commands/create' # Create command
require_relative 'jackdaw/commands/new' # New project command
require_relative 'jackdaw/commands/template' # Template management command
require_relative 'jackdaw/cli' # Main CLI entry point

# Main Jackdaw module
module Jackdaw
  # Base error class for Jackdaw-specific exceptions
  class Error < StandardError; end
end
