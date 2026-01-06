<div style="text-align: center; margin: 2rem 0;">
  <img src="/jackdaw.png" alt="Jackdaw" style="max-width: 300px; height: auto;">
</div>

# Jackdaw ⚡️

**Lightning-fast static site generator for Ruby**

Jackdaw is a minimal, fast static site generator that emphasizes:

- **Speed** - Build 600 files in under 1 second with parallel processing
- **Convention over configuration** - Zero config required to get started
- **Developer experience** - Live reload, incremental builds, intuitive CLI
- **Simplicity** - Markdown + ERB templates, that's it

## Quick Start

```bash
# Install
gem install jackdaw

# Create a new site
jackdaw new my-blog
cd my-blog.site

# Start developing
jackdaw serve
```

## Why Jackdaw?

### ⚡️ Blazing Fast
- Parallel processing for maximum speed
- Incremental builds - only rebuild what changed
- 693 files/second full build, 16,280 files/second incremental

### 🎯 Convention Over Configuration
- No configuration files needed
- Intuitive project structure
- Smart defaults that just work

### 🛠 Great Developer Experience
- Live reload development server
- Helpful CLI commands
- Clear error messages
- Ruby 4.0 ready

### 📦 Everything Included
- Markdown with GitHub-flavored syntax
- Syntax highlighting with Rouge
- Partials and layouts
- RSS/Atom feeds
- Sitemap generation
- SEO helpers

## Key Features

- **Markdown** - Write content in Markdown
- **ERB Templates** - Flexible templating with Ruby
- **Live Reload** - Changes appear instantly in browser
- **Parallel Processing** - Multi-core performance
- **Type-based Routing** - Automatic content organization
- **Incremental Builds** - Only rebuild changed files
- **RSS/Atom Feeds** - Automatic feed generation for blogs
- **Sitemap** - SEO-friendly sitemap.xml
- **Zero Config** - Convention over configuration

## Learn More

- [Installation](/installation.html) - Get Jackdaw up and running
- [Getting Started](/getting-started.html) - Your first site in 5 minutes
- [Commands](/commands.html) - Complete CLI reference
- [Templates](/templates.html) - Master templating
- [Content](/content.html) - Write and organize content

## Performance Benchmarks

| Operation | Time | Files/Second |
|-----------|------|-------------|
| Full build (600 files) | 0.87s | 693 |
| Incremental build | 0.04s | 16,280 |
| Cold start | 0.69s | 870 |

## Open Source

Jackdaw is MIT licensed and available on [GitHub](https://github.com/yourusername/jackdaw).
