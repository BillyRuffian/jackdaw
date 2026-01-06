# Jackdaw ⚡️

**Lightning-fast Ruby static site generator with convention over configuration**

Jackdaw is a minimal, fast static site generator that emphasizes:
- **Speed**: Parallel processing and incremental builds
- **Simplicity**: Convention over configuration - zero config files needed
- **Developer Experience**: Live reload, beautiful CLI output, intuitive structure

## Features

- ⚡️ **Blazing Fast**: Build 600 files in under 1 second
- 🔄 **Incremental Builds**: Only rebuilds changed files (6-18x faster)
- 🎨 **Beautiful CLI**: Colorful, informative command output
- 🔥 **Live Reload**: Auto-refresh browser on file changes
- 📝 **Markdown + ERB**: GitHub Flavored Markdown with ERB templates
- 🎯 **Convention-Based**: No configuration files required
- 🌈 **Syntax Highlighting**: Built-in code highlighting with Rouge
- 🚀 **Development Server**: Built-in server with live reload

## Performance

| Site Size | Files | Clean Build | Incremental | Files/sec |
|-----------|-------|-------------|-------------|-----------|
| Small     | 30    | 0.18s       | 0.005s      | 5,821     |
| Medium    | 150   | 0.35s       | 0.012s      | 12,343    |
| Large     | 600   | 0.87s       | 0.037s      | 16,280    |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jackdaw'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install jackdaw
```

## Quick Start

### Create a new site

```bash
$ jackdaw new my-blog
$ cd my-blog.site
```

This creates a project structure:

```
my-blog.site/
├── site/
│   ├── src/              # Your content (Markdown files)
│   ├── templates/        # ERB templates
│   └── assets/           # Static assets (CSS, images, etc.)
└── public/               # Generated output (git-ignored)
```

### Build your site

```bash
$ jackdaw build              # Build the site
$ jackdaw build --clean      # Clean build (remove old files)
$ jackdaw build --verbose    # Show detailed output
```

### Development server

```bash
$ jackdaw serve              # Start server with live reload on port 4000
$ jackdaw serve --port 3000  # Use custom port
$ jackdaw serve --no-livereload  # Disable live reload
```

Visit `http://localhost:4000` to see your site with auto-reload enabled!

### Create content

```bash
$ jackdaw create blog "My First Post"      # Creates: 2026-01-06-my-first-post.blog.md
$ jackdaw create page "About"              # Creates: about.page.md
$ jackdaw create page "company/history"    # Creates: company/history.page.md
```

### List available templates

```bash
$ jackdaw template list
```

## Project Structure

Jackdaw follows a simple, convention-based structure:

```
my-site.site/
├── site/
│   ├── src/                    # Content directory
│   │   ├── index.page.md       # Homepage
│   │   ├── about.page.md       # About page
│   │   └── blog/               # Blog posts
│   │       └── 2026-01-06-hello.blog.md
│   │
│   ├── templates/              # ERB templates
│   │   ├── layout.html.erb     # Main layout
│   │   ├── page.html.erb       # Page template
│   │   ├── blog.html.erb       # Blog post template
│   │   └── _nav.html.erb       # Partial (starts with _)
│   │
│   └── assets/                 # Static files
│       ├── styles.css
│       └── images/
│
└── public/                     # Generated output
    ├── index.html
    ├── about.html
    ├── blog/
    │   └── 2026-01-06-hello.html
    └── assets/
```

## Content Files

Content files use a naming convention: `<name>.<type>.md`

### Pages

```markdown
# About Us

Regular pages using the page template.
```

**File**: `about.page.md` → **Output**: `about.html`

### Blog Posts (with date prefixes)

```markdown
# My First Post

Blog posts automatically get date metadata from filename.
```

**File**: `2026-01-06-first-post.blog.md` → **Output**: `blog/2026-01-06-first-post.html`

### Metadata Extraction

Jackdaw automatically extracts metadata:

- **Title**: From first H1 heading (`# Title`)
- **Date**: From filename (`YYYY-MM-DD-`) or file modification time
- **Excerpt**: First 150 words
- **Reading Time**: Calculated from word count

## Templates

### Layout Template (`layout.html.erb`)

```erb
<!DOCTYPE html>
<html>
<head>
  <title><%= title %> - <%= site_name %></title>
</head>
<body>
  <%= render 'nav' %>
  <%= content %>
</body>
</html>
```

### Page Template (`page.html.erb`)

```erb
<main>
  <%= content %>
</main>
```

### Blog Template (`blog.html.erb`)

```erb
<article>
  <h1><%= title %></h1>
  <time><%= date.strftime('%B %d, %Y') %></time>
  <%= content %>
</article>
```

### Partials

Partials start with `_` and can be included with `<%= render 'name' %>`

**File**: `_nav.html.erb`

```erb
<nav>
  <a href="/">Home</a>
  <a href="/blog">Blog</a>
</nav>
```

**Usage**: `<%= render 'nav' %>`

## Template Variables

Available in all templates:

| Variable | Description |
|----------|-------------|
| `<%= content %>` | Rendered markdown content |
| `<%= title %>` | Page title (from H1) |
| `<%= date %>` | Post date (Date object) |
| `<%= excerpt %>` | First 150 words |
| `<%= reading_time %>` | Estimated minutes to read |
| `<%= site_name %>` | Site name (from directory) |
| `<%= all_posts %>` | Array of all blog posts |
| `<%= all_pages %>` | Array of all pages |

## Syntax Highlighting

Code blocks are automatically highlighted:

````markdown
```ruby
def hello
  puts "Hello, World!"
end
```
````

## Creating Custom Templates

1. Create a new template file: `templates/project.html.erb`
2. Add your template code
3. Create content with: `jackdaw create project "My Project"`

Dated templates (auto-prefix with date):
- `blog`, `post`, `article`, `news`

Override with flags:
```bash
$ jackdaw create page "Timeline" --dated      # Add date to page
$ jackdaw create blog "Timeless" --no-date    # Remove date from blog
```

## CLI Commands

### `jackdaw new <name>`

Create a new site project with starter templates and example content.

```bash
$ jackdaw new my-blog
$ cd my-blog.site
```

### `jackdaw build [options]`

Build the static site.

**Options:**
- `--clean, -c` Clean output directory before building
- `--verbose, -v` Show detailed output

```bash
$ jackdaw build           # Incremental build
$ jackdaw build --clean   # Full rebuild
```

### `jackdaw serve [options]`

Start development server with live reload.

**Options:**
- `--port, -p PORT` Server port (default: 4000)
- `--host, -h HOST` Server host (default: localhost)
- `--no-livereload` Disable live reload

```bash
$ jackdaw serve                    # Start on port 4000
$ jackdaw serve --port 3000        # Use port 3000
$ jackdaw serve --no-livereload    # No auto-refresh
```

### `jackdaw create <template> <name> [options]`

Create a new content file from template.

**Options:**
- `--dated` Add date prefix to filename
- `--no-date` Skip date prefix

```bash
$ jackdaw create blog "First Post"           # → 2026-01-06-first-post.blog.md
$ jackdaw create page "About"                # → about.page.md
$ jackdaw create page "company/team"         # → company/team.page.md
$ jackdaw create page "Timeline" --dated     # → 2026-01-06-timeline.page.md
```

### `jackdaw template list`

List all available templates.

```bash
$ jackdaw template list
```

### `jackdaw version`

Show Jackdaw version.

```bash
$ jackdaw version
```

## How It Works

### Build Process

1. **Scan**: Discover all content, template, and asset files
2. **Check**: Determine which files need rebuilding (mtime-based)
3. **Process**: Render content in parallel using all CPU cores
4. **Write**: Output HTML files to public/ directory
5. **Copy**: Copy assets to public/assets/

### Incremental Builds

Jackdaw uses modification time (mtime) checking to only rebuild files when:
- Content file changed
- Template file changed
- Layout file changed

This makes rebuilds **6-18x faster** than clean builds.

### Live Reload

The development server watches for file changes and:
1. Detects changes using the Listen gem
2. Triggers incremental rebuild
3. Injects JavaScript that polls for changes
4. Refreshes browser automatically

## Best Practices

### Content Organization

```
src/
├── index.page.md           # Homepage
├── about.page.md           # Top-level pages
├── blog/                   # Blog posts by category
│   └── 2026-01-06-post.blog.md
└── projects/               # Nested content
    └── project-name.page.md
```

### Template Naming

- Main layout: `layout.html.erb` (required)
- Content templates: `<type>.html.erb` (e.g., `blog.html.erb`)
- Partials: `_<name>.html.erb` (e.g., `_header.html.erb`)

### Dated Content

Use dated types for time-based content:
- `blog` - Blog posts
- `post` - General posts
- `article` - Articles
- `news` - News items

Use non-dated types for static content:
- `page` - Pages
- `project` - Projects
- Any custom type

## Deployment

Jackdaw generates static HTML files in the `public/` directory. Deploy to any static host:

### Netlify / Vercel

```bash
$ jackdaw build
# Deploy public/ directory
```

### GitHub Pages

```bash
$ jackdaw build
$ cd public
$ git init
$ git add .
$ git commit -m "Deploy"
$ git push origin gh-pages
```

### Nginx / Apache

Copy `public/` contents to your web server's document root.

## Troubleshooting

### Server won't start

Make sure you're in a `.site` directory:

```bash
$ jackdaw serve
✗ No site directory found. Run this command from a .site directory.
```

### Template not found

List available templates:

```bash
$ jackdaw template list
```

### Build errors

Run with verbose flag to see details:

```bash
$ jackdaw build --verbose
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Built with:
- [Thor](https://github.com/rails/thor) - CLI framework
- [Kramdown](https://kramdown.gettalong.org/) - Markdown parser
- [Rouge](https://github.com/rouge-ruby/rouge) - Syntax highlighting
- [Parallel](https://github.com/grosser/parallel) - Multi-threading
- [Listen](https://github.com/guard/listen) - File watching
- [Puma](https://puma.io/) - Web server
- [Rack](https://github.com/rack/rack) - Web server interface

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jackdaw.
