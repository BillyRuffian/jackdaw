# Commands Reference

Complete reference for all Jackdaw CLI commands.

## jackdaw new

Create a new site project with starter templates.

```bash
jackdaw new NAME
```

**Examples:**
```bash
jackdaw new my-blog
jackdaw new company-site.site  # .site not duplicated
```

Creates:
- Directory structure
- Starter templates (layout, page, blog)
- Example content
- `.gitignore`

## jackdaw build

Build the static site.

```bash
jackdaw build [OPTIONS]
```

**Options:**
- `--clean` - Remove old files before building
- `--verbose` - Show detailed build information

**Examples:**
```bash
jackdaw build              # Incremental build
jackdaw build --clean      # Full rebuild
jackdaw build --verbose    # Detailed output
```

**What it does:**
1. Scans content, templates, and assets
2. Renders Markdown → HTML
3. Applies ERB templates
4. Copies static assets
5. Generates RSS/Atom feeds (if blog posts exist)
6. Generates sitemap.xml

**Output:** `public/` directory

## jackdaw serve

Start development server with live reload.

```bash
jackdaw serve [OPTIONS]
```

**Options:**
- `--port PORT` - Server port (default: 4000)
- `--no-livereload` - Disable automatic browser refresh

**Examples:**
```bash
jackdaw serve                    # Start on port 4000
jackdaw serve --port 3000        # Custom port
jackdaw serve --no-livereload    # No auto-refresh
```

**Features:**
- Builds site on start
- Watches for file changes
- Auto-rebuilds on change
- Live reload in browser
- Serves from `public/`

Access at `http://localhost:4000`

## jackdaw create

Create new content from templates.

```bash
jackdaw create TEMPLATE NAME [OPTIONS]
```

**Options:**
- `--dated` - Add date prefix (for pages)
- `--no-date` - Skip date prefix (for blog posts)

**Examples:**
```bash
# Blog post (auto-dated)
jackdaw create blog "My First Post"
# → 2026-01-06-my-first-post.blog.md

# Page (no date)
jackdaw create page "About"
# → about.page.md

# Nested paths
jackdaw create page "docs/installation"
# → docs/installation.page.md

# Force date on page
jackdaw create page "Timeline" --dated
# → 2026-01-06-timeline.page.md

# Remove date from blog
jackdaw create blog "Timeless" --no-date
# → timeless.blog.md
```

**Template types:**
- `blog` - Blog posts (dated by default)
- `page` - Static pages (no date)
- `post` - Alternative to blog
- `article` - Alternative to blog
- Custom types you create

## jackdaw template

Manage content templates.

```bash
jackdaw template SUBCOMMAND
```

### template list

List all available templates in `site/templates/`.

```bash
jackdaw template list
```

Shows templates you can use with `jackdaw create`.

## jackdaw version

Display Jackdaw version.

```bash
jackdaw version
```

## jackdaw help

Show help for commands.

```bash
jackdaw help              # All commands
jackdaw help build        # Specific command
```

## Command Workflow

Typical development workflow:

```bash
# Initial setup
jackdaw new my-site
cd my-site.site

# Development
jackdaw serve             # Start dev server
# Edit files, see changes instantly

# Create content as needed
jackdaw create blog "New Post"
jackdaw create page "Contact"

# Production build
jackdaw build --clean

# Deploy (copy public/ to server)
```

## Exit Codes

- `0` - Success
- `1` - Error (with message)
