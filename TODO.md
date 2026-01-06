# Jackdaw - Static Site Generator TODO

## Project Overview
A fast, incremental static site generator with folder-based organization using Thor for CLI.

---

## Phase 1: Project Setup
- [x] Add Thor gem dependency to gemspec
- [x] Add development dependencies (rspec, rubocop, etc.)
- [x] Create basic CLI structure in exe/jackdaw
- [x] Set up Thor CLI class structure
- [x] Add any additional dependencies (for markdown parsing, file watching, etc.)

## Phase 2: Core File System Structure
- [x] Define standard project structure (site/ directory)
- [x] Create file watcher/tracker for incremental builds
- [x] Implement directory scanner
- [x] Create file type registry (.page, .post, etc.)
- [x] Build metadata extractor from file structure (path, name, dates)
- [x] Extract metadata from first heading as title (H1)
- [x] Implement content type handlers
  - [x] Page handler
  - [x] Post handler
  - [x] Asset handler

## Phase 3: Template System
- [x] Design template engine integration (ERB)
- [x] Implement template loader from templates/ directory
- [x] Create template context builder
- [x] Add layout/partial support
- [x] Implement template caching for performance

## Phase 4: Content Processing
- [x] Implement markdown parser integration
- [x] Create content preprocessor pipeline
- [x] Extract metadata from filename (dates, slugs)
- [x] Extract title from first H1 in content
- [x] Derive metadata from folder structure and hierarchy
- [x] Implement content transformation pipeline
- [x] Add syntax highlighting support (Rouge)

## Phase 5: Build System
- [x] Design dependency graph for incremental builds
- [x] Implement file change detection
- [x] Create build cache system
- [x] Build output directory management (public/)
- [x] Implement parallel processing for speed
- [x] Add build statistics/reporting
- [x] Create clean build option

## Phase 6: CLI Commands - Build
- [x] Implement `jackdaw build` command
  - [x] Full build option
  - [x] Incremental build (default)
  - [x] Watch mode option (deferred to serve command)
  - [x] Verbose/debug output
  - [x] Clean option
- [x] Add build configuration loading (skipped - convention over configuration)
- [x] Implement error handling and reporting

## Phase 7: CLI Commands - Serve
- [x] Implement `jackdaw serve` command
- [x] Choose and integrate web server (Puma with Rack)
- [x] Add live reload support (polling-based with JavaScript)
- [x] Implement file watching for auto-rebuild (Listen gem)
- [x] Configure port and host options
- [x] Add middleware for development (StaticFileServer + LiveReloadMiddleware)
- [x] Beautiful CLI output with rebuild stats
- [x] Graceful shutdown handling (Ctrl+C)

## Phase 8: CLI Commands - Create
- [x] Implement `jackdaw create <template> <name>` command
- [x] Create template scaffolding system
- [x] Add default built-in templates:
  - [x] `page` template (basic page.html.erb)
  - [x] `blog` template (blog post with date handling)
- [x] Support arbitrary user-defined templates in templates/ directory
- [x] Discover available templates from templates/ folder
- [x] Add date/timestamp handling for posts (auto-prefix for blog/post/article/news)
- [x] Allow users to add custom templates by creating template files
- [x] Implement `jackdaw template list` command
- [x] Add --dated and --no-date flags for override control
- [x] Support nested paths (e.g., `jackdaw create page company/about`)
- [x] Validate template existence before creating files
- [x] Add Builder warnings for missing templates

## Phase 9: Configuration System
- [x] Skipped - Maintaining config-less, convention-over-configuration approach

## Phase 10: Asset Handling
- [x] Implement asset copying
- [x] Keeping minimal - assets copied as-is for speed and simplicity

## Phase 11: Performance Optimization
- [x] Profile build performance
- [x] Implement multi-threading for file processing (Parallel gem)
- [x] Optimize file I/O operations (incremental builds with mtime checks)
- [ ] Add memory usage optimization
- [x] Benchmark against common static site generators
  - Small (30 files): 164 files/sec clean, 5821 files/sec incremental
  - Medium (150 files): 428 files/sec clean, 12343 files/sec incremental
  - Large (600 files): 693 files/sec clean, 16280 files/sec incremental
  - Incremental builds: 6-18x faster than clean builds
- [x] Cache template compilation (ERB caching in Renderer)
- [x] Optimize dependency graph traversal (mtime-based change detection)

## Phase 12: Documentation
- [x] Write comprehensive README with quickstart guide
- [x] Document CLI commands and options (in README)
- [x] Create project structure guide (in README)
- [x] Write template documentation (in README)
- [x] Add configuration reference (N/A - convention-based, no config needed)
- [x] Add troubleshooting guide (in README)
- [x] Consolidate all require statements to jackdaw.rb
- [x] Add comprehensive code comments to jackdaw.rb and project.rb
- [ ] Add code comments to remaining core files
- [ ] Create example site (basic example already created by `jackdaw new`)

## Phase 13: Testing
- [x] Unit tests for core components (Project, FileTypes, Scanner)
- [x] Unit tests for Renderer (21 tests)
- [x] Integration tests for Builder (18 tests)
- [x] End-to-end build tests (10 comprehensive workflow tests)
- [x] Test helper infrastructure with fixtures
- [x] Performance benchmarks (completed in Phase 11)
- **Total: 99 passing tests, 0 failures**

## Phase 14: Polish & Release
- [x] Code cleanup and refactoring (reduced complexity in Build command)
- [x] RuboCop compliance (all files passing, 0 offenses)
- [x] Error message improvements (beautiful CLI output with colors)
- [x] Add progress indicators (build stats, rebuild notifications)
- [x] Version 1.0.0 release preparation
  - [x] Updated version to 1.0.0
  - [x] Created comprehensive CHANGELOG.md
  - [x] Updated gemspec with proper metadata
  - [x] All 99 tests passing
- [ ] Publish to RubyGems (deferred)

## Phase 15: Essential Web Features
- [ ] RSS/Atom feed generation (for blog posts)
- [ ] Sitemap.xml generation (for SEO)
- [ ] SEO meta tag helpers (Open Graph, Twitter Cards)

---

## Nice-to-Have Features (Future)
- [ ] Search index generation (JSON for client-side search)
- [ ] Git integration (simple deploy command wrapper)

## Won't Implement (Against Project Philosophy)
- ~~Multiple template engine support~~ - ERB is sufficient, adds complexity
- ~~Image lazy loading helpers~~ - Can be done in templates/CSS
- ~~i18n/l10n support~~ - Too complex, users can handle with folder structure
- ~~CloudFlare/Netlify deployment helpers~~ - Too specific, manual deploy is simple enough

---

## Technical Decisions to Make
- [x] Template engine: ERB (built-in, fast, zero dependencies)
- [x] Markdown parser: Kramdown (pure Ruby, no compilation issues)
- [x] Server: Puma (fast, industry standard)
- [x] File watching: Listen gem (reliable, cross-platform)
- [ ] Config format: YAML vs TOML vs Ruby DSL? (may skip - convention over configuration)
- [x] Incremental build strategy: Timestamp-based (mtime checks)
- [x] Metadata approach: Convention-based (NO frontmatter, derive from structure/content)
