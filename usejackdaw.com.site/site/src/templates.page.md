# Template Guide

Learn how to create powerful, flexible templates with ERB.

## Template Basics

Templates are ERB files in `site/templates/` that wrap your content.

**Basic template** (`site/templates/page.html.erb`):

```erb
<!DOCTYPE html>
<html>
<head>
  <title><%= title %></title>
</head>
<body>
  <%= content %>
</body>
</html>
```

## Template Naming

Templates match content types:

- `page.html.erb` - Used by `*.page.md` files
- `blog.html.erb` - Used by `*.blog.md` files
- `post.html.erb` - Used by `*.post.md` files

## Available Variables

In templates, you have access to:

### Content Variables

```erb
<%= content %>         <!-- Rendered HTML from Markdown -->
<%= title %>           <!-- From first H1 or filename -->
<%= date %>            <!-- Date object (if dated content) -->
<%= type %>            <!-- Content type (page, blog, etc) -->
<%= excerpt %>         <!-- First paragraph -->
<%= raw_content %>     <!-- Original Markdown -->
```

## Layouts

Create a layout for all pages:

**`site/templates/layout.html.erb`:**

```erb
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= title %> - My Site</title>
  <%= seo_tags %>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <%= render_partial('nav') %>
  
  <main>
    <%= content %>
  </main>
  
  <%= render_partial('footer') %>
</body>
</html>
```

**Use in page template:**

```erb
<%= render_layout('layout') do %>
  <article>
    <h1><%= title %></h1>
    <%= content %>
  </article>
<% end %>
```

## Partials

Reusable template fragments in `site/templates/partials/`.

**Create** (`site/templates/partials/nav.html.erb`):

```erb
<nav>
  <ul>
    <li><a href="/">Home</a></li>
    <li><a href="/about.html">About</a></li>
    <li><a href="/blog.html">Blog</a></li>
  </ul>
</nav>
```

**Use in templates:**

```erb
<%= render_partial('nav') %>
```

With variables:

```erb
<%= render_partial('card', { title: 'Hello', text: 'World' }) %>
```

## Collections

Loop through content:

```erb
<h2>Recent Posts</h2>
<ul>
  <% collection('blog', limit: 5).each do |post| %>
    <li>
      <a href="/<%= post.output_path %>">
        <%= post.title %>
      </a>
      <time><%= post.date.strftime('%B %d, %Y') %></time>
    </li>
  <% end %>
</ul>
```

**Options:**
- `limit: 10` - Maximum items
- `sort: :date` - Sort by field (default: date)
- `reverse: true` - Newest first (default)

**Examples:**

```erb
<!-- All blog posts -->
<% collection('blog').each do |post| %>
  ...
<% end %>

<!-- Latest 3 posts -->
<% collection('blog', limit: 3).each do |post| %>
  ...
<% end %>

<!-- All pages -->
<% collection('page').each do |page| %>
  ...
<% end %>
```

## SEO Helpers

Built-in helpers for SEO:

### Complete SEO Tags

```erb
<%= seo_tags %>
```

Generates:
- Open Graph tags
- Twitter Card tags
- Canonical URL
- Meta description

### Individual Tags

```erb
<%= og_tags %>              <!-- Open Graph -->
<%= twitter_tags %>         <!-- Twitter Cards -->
<%= canonical_tag %>        <!-- Canonical URL -->
<%= meta_description %>     <!-- Description meta tag -->
```

**With custom values:**

```erb
<%= og_tags(
  title: "Custom Title",
  description: "Custom description",
  image: "/images/og-image.png"
) %>
```

## Date Formatting

```erb
<!-- Full date -->
<%= date.strftime('%B %d, %Y') %>
<!-- January 06, 2026 -->

<!-- Short date -->
<%= date.strftime('%Y-%m-%d') %>
<!-- 2026-01-06 -->

<!-- Custom -->
<%= date.strftime('%A, %b %e') %>
<!-- Monday, Jan  6 -->
```

## Conditional Content

```erb
<% if defined?(date) && date %>
  <time><%= date.strftime('%B %d, %Y') %></time>
<% end %>

<% if type == 'blog' %>
  <span class="blog-badge">Blog Post</span>
<% end %>
```

## Example Templates

### Blog Post Template

```erb
<!DOCTYPE html>
<html>
<head>
  <title><%= title %> - My Blog</title>
  <%= seo_tags %>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <%= render_partial('nav') %>
  
  <article class="blog-post">
    <header>
      <h1><%= title %></h1>
      <time datetime="<%= date.iso8601 %>">
        <%= date.strftime('%B %d, %Y') %>
      </time>
    </header>
    
    <div class="content">
      <%= content %>
    </div>
  </article>
  
  <%= render_partial('footer') %>
</body>
</html>
```

### Blog Index Template

```erb
<!DOCTYPE html>
<html>
<head>
  <title>Blog</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <%= render_partial('nav') %>
  
  <h1>Blog</h1>
  
  <div class="posts">
    <% collection('blog', limit: 20).each do |post| %>
      <article class="post-preview">
        <h2>
          <a href="/<%= post.output_path %>">
            <%= post.title %>
          </a>
        </h2>
        <time><%= post.date.strftime('%B %d, %Y') %></time>
        <p><%= post.excerpt %></p>
        <a href="/<%= post.output_path %>">Read more →</a>
      </article>
    <% end %>
  </div>
  
  <%= render_partial('footer') %>
</body>
</html>
```

## Tips

1. **Keep it simple** - Start with basic templates
2. **Use partials** - DRY up repeated HTML
3. **Default values** - Use `||` for defaults:
   ```erb
   <%= title || 'Untitled' %>
   ```
4. **Check existence** - Use `defined?` for optional variables
5. **Extract layouts** - Share structure across templates
