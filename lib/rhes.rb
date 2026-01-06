# frozen_string_literal: true

#
# RHES - Lightning-fast Ruby static site generator
#
# This is the main entry point for the RHES gem. It loads all dependencies
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
require_relative 'rhes/version'
require_relative 'rhes/project'        # Project structure management
require_relative 'rhes/file_types'     # Content, Template, and Asset file abstractions
require_relative 'rhes/scanner'        # Directory scanning
require_relative 'rhes/seo_helpers'    # SEO meta tag helpers (must be before renderer)
require_relative 'rhes/renderer'       # ERB and Markdown rendering
require_relative 'rhes/feed_generator' # RSS/Atom feed generation
require_relative 'rhes/sitemap_generator' # Sitemap.xml generation
require_relative 'rhes/builder'        # Build orchestration
require_relative 'rhes/watcher'        # File watching
require_relative 'rhes/server'         # Development server
require_relative 'rhes/cli_helpers'    # Shared CLI utilities
require_relative 'rhes/commands/build' # Build command
require_relative 'rhes/commands/serve' # Serve command
require_relative 'rhes/commands/create' # Create command
require_relative 'rhes/commands/new' # New project command
require_relative 'rhes/commands/template' # Template management command
require_relative 'rhes/cli' # Main CLI entry point

# Main Jackdaw module
module Jackdaw
  # Base error class for Jackdaw-specific exceptions
  class Error < StandardError; end
end
