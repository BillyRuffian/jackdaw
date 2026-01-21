# Changelog

All notable changes to Jackdaw will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.0.5] - 2026-01-21

### Added
- Added robots.txt scaffolding to `jackdaw new` - allows all crawlers by default for better SEO

### Fixed
- gemspec links to correct repos and homepage

## [1.0.4] - 2026-01-08

### Fixed
- Fixed hot reload functionality in development server - browser now properly detects file changes and refreshes automatically
- Improved live reload middleware to use build counter instead of timestamps for more reliable change detection
- Fixed partial template changes not triggering rebuilds - changes to partials (e.g., `_nav.html.erb`, `_footer.html.erb`) now properly rebuild all affected pages
- Fixed build statistics accumulating across multiple rebuilds - stats now reset correctly for each build
- Added hot reload support for assets (CSS, JS, images) - changes to assets now trigger browser refresh with cache-busting

## [1.0.0] - 2026-01-06

### Added
- **Core Features**
  - Lightning-fast static site generation with parallel processing
  - Incremental builds (6-18x faster than clean builds)
  - Convention-over-configuration approach (zero config files needed)
  - Beautiful CLI with colorful output and emojis
  - Live reload development server with auto-refresh
  - GitHub Flavored Markdown with syntax highlighting (Rouge)
  - ERB template system with layouts and partials

- **CLI Commands**
  - `jackdaw new <name>` - Create new site project with starter templates
  - `jackdaw build` - Build static site with incremental and clean options
  - `jackdaw serve` - Development server with live reload
  - `jackdaw create <type> <name>` - Create new content from templates
  - `jackdaw template list` - List available content templates
  - `jackdaw version` - Show version information

- **Project Structure**
  - Convention-based directory layout (site/src, site/templates, site/assets, public/)
  - Double-extension content files (name.type.md)
  - Automatic date extraction from filenames (YYYY-MM-DD-name.type.md)
  - Template discovery and validation

- **Content Processing**
  - Automatic metadata extraction (title, date, excerpt, reading time)
  - Smart content type detection
  - Nested directory structure preservation
  - Asset copying with directory structure maintenance

- **Template System**
  - ERB template rendering with full context
  - Layout wrapping (layout.html.erb)
  - Partial includes with render helper
  - Template caching for performance
  - Access to all_posts and all_pages collections
  - Site name inference from directory

- **Performance**
  - Multi-threaded parallel processing (uses all CPU cores)
  - Smart incremental builds with mtime-based change detection
  - Template compilation caching
  - Benchmark results:
    - Small sites (30 files): 5,821 files/sec incremental
    - Medium sites (150 files): 12,343 files/sec incremental
    - Large sites (600 files): 16,280 files/sec incremental

- **Development Experience**
  - Live reload with file watching (Listen gem)
  - Beautiful CLI output with ANSI colors
  - Detailed build statistics
  - Verbose mode for debugging
  - Comprehensive error messages

- **Testing**
  - 99 comprehensive tests covering all components
  - Unit tests for core classes
  - Integration tests for build pipeline
  - End-to-end workflow tests
  - Test fixtures and helpers

### Technical Details
- Ruby 4.0+ compatible
- Dependencies: Thor, Kramdown, Rouge, Parallel, Listen, Puma, Rack
- RuboCop compliant
- Comprehensive documentation

### Performance Benchmarks
- Clean build: 164-693 files/sec
- Incremental build: 5,821-16,280 files/sec
- Build 600 files in under 1 second

[1.0.0]: https://github.com/yourusername/jackdaw/releases/tag/v1.0.0
