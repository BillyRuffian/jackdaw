<div class="hero" markdown="1">

<img src="/jackdaw.png" alt="Jackdaw">

<p style="font-size: 1.3rem; color: #666; margin: 1rem 0;"><strong>Lightning-fast static site generator for Ruby</strong></p>

</div>

<div class="content" markdown="1">

Jackdaw is a minimal, fast static site generator that emphasises:

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

</div>

<div class="content" markdown="1">

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

</div>

<div class="content" markdown="1">

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

</div>

<div class="content" markdown="1">

## Learn More

- [Installation](/installation.html) - Get Jackdaw up and running
- [Getting Started](/getting-started.html) - Your first site in 5 minutes
- [Commands](/commands.html) - Complete CLI reference
- [Templates](/templates.html) - Master templating
- [Content](/content.html) - Write and organize content

</div>

<div class="content" markdown="1">

## Performance Benchmarks

| Operation | Time | Files/Second |
|-----------|------|-------------|
| Full build (600 files) | 0.87s | 693 |
| Incremental build | 0.04s | 16,280 |
| Cold start | 0.69s | 870 |

</div>

## Open Source

Jackdaw is MIT licensed and available on [GitHub](https://github.com/yourusername/jackdaw).
