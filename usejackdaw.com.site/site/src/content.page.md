# Content Guide

Everything you need to know about creating content in Jackdaw.

## Content Files

Content is written in Markdown in `site/src/`.

### File Naming Convention

```
[date-]name.type.md
```

**Examples:**
- `index.page.md` → `/index.html` (homepage)
- `about.page.md` → `/about.html` (page)
- `2026-01-06-hello.blog.md` → `/2026-01-06-hello.html` (blog post)
- `docs/guide.page.md` → `/docs/guide.html` (nested)

### Content Types

The `.type.` part determines template and behavior:

- **page** - Static pages (no date required)
- **blog** - Blog posts (dated)
- **post** - Alternative to blog
- **article** - Alternative to blog
- **Custom** - Create your own types

## Title Extraction

Jackdaw extracts titles from:
category: Tutorial
featured: true
image: /images/hero.jpg
---
```

Access in templates:
```erb
<% if featured %>
  <span class="badge">Featured</span>
<% end %>
```

## Writing Markdown

Jackdaw uses GitHub-flavored Markdown via Kramdown.

### Headings

```markdown
# Heading 1
## Heading 2
### Heading 3
```

### Text Formatting

```markdown
**bold** or __bold__
*italic* or _italic_
~~strikethrough~~
`code`
```

### Links

```markdown
[Link text](https://example.com)
[Relative link](/about.html)
[Link with title](https://example.com "Title")
```

### Images

```markdown
![Alt text](/images/photo.jpg)
![With title](/images/photo.jpg "Photo title")
```

### Lists

```markdown
- Unordered item
- Another item
  - Nested item

1. Ordered item
2. Another item
   1. Nested ordered
```

### Code Blocks

With syntax highlighting:

````markdown
```ruby
def hello
  puts "Hello, world!"
end
```
````

Supported languages: Ruby, JavaScript, Python, HTML, CSS, Shell, and 200+ more.

### Blockquotes

```markdown
> This is a quote
> spanning multiple lines
```

### Tables

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
```

### Horizontal Rules

```markdown
---
```

### HTML

You can include HTML:

```markdown
<div class="custom">
  Regular markdown **works** here too.
</div>
```

## Automatic Excerpt

The first paragraph becomes the excerpt:

```markdown

This paragraph is automatically used as the excerpt.

This is regular content.
```

## Nested Content

Organize with directories:

```
site/src/
├── index.page.md
├── about.page.md
├── blog/
│   ├── 2026-01-01-first.blog.md
│   └── 2026-01-02-second.blog.md
└── docs/
    ├── getting-started.page.md
    └── api.page.md
```

URLs match structure:
- `blog/2026-01-01-first.blog.md` → `/blog/2026-01-01-first.html`
- `docs/api.page.md` → `/docs/api.html`

## Dates

### Automatic Date Extraction

Jackdaw extracts dates from filenames:

```
2026-01-06-post-name.blog.md
^         ^
Date      │
          Title
```

Formats:
- `YYYY-MM-DD-title.type.md`
- `YYYY-MM-title.type.md`  
- `YYYY-title.type.md`

### No Date

For pages that don't need dates:

```
about.page.md  # No date in filename
```

## Title Extraction

Jackdaw extracts titles from:

1. **First H1** in content (highest priority):
   ```markdown
   # This Becomes the Title
   ```

2. **Filename** (fallback):
   ```
   my-awesome-post.blog.md
   → "My Awesome Post"
   ```

## Content Organization Patterns

### Blog

```
site/src/
├── index.page.md                    # Blog homepage
└── blog/
    ├── 2026-01-01-hello.blog.md
    ├── 2026-01-02-second.blog.md
    └── 2026-01-03-third.blog.md
```

### Documentation Site

```
site/src/
├── index.page.md                    # Docs homepage
├── getting-started.page.md
├── installation.page.md
└── guides/
    ├── basics.page.md
    ├── advanced.page.md
    └── api.page.md
```

### Marketing Site

```
site/src/
├── index.page.md                    # Homepage
├── about.page.md
├── pricing.page.md
├── contact.page.md
└── blog/
    └── 2026-01-01-announcement.blog.md
```

## RSS/Atom Feeds

Feeds are automatically generated for blog content:

- `public/feed.xml` (RSS 2.0)
- `public/atom.xml` (Atom 1.0)

Includes:
- 20 most recent posts
- Title, link, date
- Excerpt/description

## Sitemap

`public/sitemap.xml` is automatically generated with:

- All pages and posts
- Correct priorities (1.0 for index, 0.8 for pages, 0.6 for posts)
- Change frequency hints
- Last modification dates

## Best Practices

1. **Use descriptive filenames** - They become URLs
2. **Add excerpts** - First paragraph is used as excerpt
3. **Organize with directories** - Keep related content together
4. **Include dates for time-sensitive content**
5. **Write semantic Markdown** - Use proper headings hierarchy
6. **Add alt text to images** - For accessibility

## Tips

- **Test locally** - Use `jackdaw serve` to preview
- **Incremental builds** - Only changed files rebuild
- **Link relatively** - Use `/about.html` not `https://...`
- **Check output** - Look in `public/` to verify
