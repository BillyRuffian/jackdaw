# Getting Started

Get your first site up and running in 5 minutes.

## Create a New Site

```bash
jackdaw new my-blog
cd my-blog.site
```

This creates a new directory with the following structure:

```
my-blog.site/
├── site/
│   ├── src/           # Your content (Markdown files)
│   ├── templates/     # ERB templates
│   └── assets/        # Static files (CSS, images, JS)
└── public/            # Generated site (after build)
```

## Project Structure

### Content (`site/src/`)

Write your content in Markdown:

```markdown
# Hello World

This is my first post!
```

File naming convention: `[date-]name.type.md`

- `index.page.md` → `/index.html`
- `about.page.md` → `/about.html`
- `2026-01-06-hello.blog.md` → `/2026-01-06-hello.html`

### Templates (`site/templates/`)

ERB templates with access to content:

```erb
<!DOCTYPE html>
<html>
<head>
  <title><%= title %></title>
</head>
<body>
  <h1><%= title %></h1>
  <%= content %>
</body>
</html>
```

### Assets (`site/assets/`)

Static files copied as-is to output:

- CSS stylesheets
- JavaScript files
- Images
- Fonts

## Build Your Site

```bash
# Full build
jackdaw build

# Clean build (remove old files first)
jackdaw build --clean

# Verbose output
jackdaw build --verbose
```

Output goes to `public/` directory.

## Development Server

Start the dev server with live reload:

```bash
jackdaw serve
```

Visit http://localhost:4000 and edit your files - changes appear instantly!

Options:
```bash
jackdaw serve --port 3000        # Custom port
jackdaw serve --no-livereload    # Disable live reload
```

## Create Content

Use templates to quickly create new content:

```bash
# Create a blog post
jackdaw create blog "My First Post"
# → Creates: 2026-01-06-my-first-post.blog.md

# Create a page
jackdaw create page "About"
# → Creates: about.page.md

# Create in subdirectory
jackdaw create page "docs/installation"
# → Creates: docs/installation.page.md
```

List available templates:
```bash
jackdaw template list
```

## Your First Blog Post

Let's create a blog:

1. **Create blog template** (`site/templates/blog.html.erb`):

```erb
<!DOCTYPE html>
<html>
<head>
  <title><%= title %></title>
  <meta name="description" content="<%= excerpt %>">
</head>
<body>
  <article>
    <h1><%= title %></h1>
    <time><%= date.strftime('%B %d, %Y') %></time>
    <%= content %>
  </article>
</body>
</html>
```

2. **Create a post**:

```bash
jackdaw create blog "Building Fast Sites"
```

3. **Edit the content** (`site/src/2026-01-06-building-fast-sites.blog.md`):

```markdown

# Building Fast Sites

Static sites are fast, secure, and easy to deploy.

## Why Static?

- **Speed** - No database queries
- **Security** - No server-side code
- **Scalability** - Just files on a CDN
```

4. **Build and view**:

```bash
jackdaw serve
```

## What's Next?

- [Commands Reference](/commands.html) - All CLI commands
- [Template Guide](/templates.html) - Master templating
- [Content Guide](/content.html) - Organizing content
- [Deployment](/deployment.html) - Go live
