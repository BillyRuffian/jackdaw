# Deployment

Deploy your static site to any hosting platform.

## Build for Production

```bash
jackdaw build --clean
```

This creates a `public/` directory with your complete site.

## Static Hosts

### Netlify

**1. Install Netlify CLI:**
```bash
npm install -g netlify-cli
```

**2. Deploy:**
```bash
cd public
netlify deploy --prod
```

Or connect your Git repository for automatic deployments.

**netlify.toml:**
```toml
[build]
  command = "gem install jackdaw && jackdaw build"
  publish = "public"

[build.environment]
  RUBY_VERSION = "4.0.0"
```

### Vercel

**1. Install Vercel CLI:**
```bash
npm install -g vercel
```

**2. Deploy:**
```bash
vercel --prod
```

**vercel.json:**
```json
{
  "buildCommand": "gem install jackdaw && jackdaw build",
  "outputDirectory": "public"
}
```

### GitHub Pages

**1. Build locally:**
```bash
jackdaw build
```

**2. Push to gh-pages branch:**
```bash
cd public
git init
git add .
git commit -m "Deploy"
git remote add origin https://github.com/username/repo.git
git push -f origin master:gh-pages
```

Or use GitHub Actions:

**.github/workflows/deploy.yml:**
```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 4.0
      
      - run: gem install jackdaw
      - run: jackdaw build
      
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

### Cloudflare Pages

Connect your Git repository and configure:

- **Build command:** `gem install jackdaw && jackdaw build`
- **Build output directory:** `public`
- **Environment variables:**
  - `RUBY_VERSION = 4.0.0`

### AWS S3 + CloudFront

**1. Build:**
```bash
jackdaw build
```

**2. Upload to S3:**
```bash
aws s3 sync public/ s3://your-bucket/ --delete
```

**3. Invalidate CloudFront cache:**
```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR_ID \
  --paths "/*"
```

### Simple Server

Any web server that serves static files:

**nginx:**
```nginx
server {
  listen 80;
  server_name example.com;
  root /var/www/public;
  
  location / {
    try_files $uri $uri/ =404;
  }
}
```

**Apache:**
```apache
<VirtualHost *:80>
  ServerName example.com
  DocumentRoot /var/www/public
  
  <Directory /var/www/public>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
```

## Custom Domain

### DNS Configuration

Point your domain to your host:

**Netlify/Vercel:**
- Add CNAME record: `www` → `your-site.netlify.app`
- Or use their nameservers

**CloudFlare Pages:**
- Add CNAME: `www` → `your-site.pages.dev`

**GitHub Pages:**
- Add CNAME file in `public/` with your domain
- Add A records:
  ```
  185.199.108.153
  185.199.109.153
  185.199.110.153
  185.199.111.153
  ```

## SSL/HTTPS

All modern hosts provide free SSL:

- **Netlify** - Automatic with Let's Encrypt
- **Vercel** - Automatic
- **CloudFlare** - Automatic
- **GitHub Pages** - Automatic for custom domains

## Optimization Tips

### Before Deploy

```bash
# Clean build
jackdaw build --clean

# Minify CSS (optional)
npx cssnano public/css/*.css

# Optimize images
npx imagemin public/images/* --out-dir=public/images
```

### Performance

1. **Use a CDN** - Most hosts provide this
2. **Enable compression** - Gzip/Brotli
3. **Set cache headers** - Long TTL for assets
4. **Optimize images** - WebP, proper sizing
5. **Minify assets** - CSS, JS

### SEO

1. **Sitemap** - Automatically generated at `/sitemap.xml`
2. **RSS feeds** - Automatically at `/feed.xml` and `/atom.xml`
3. **SEO tags** - Use `<%= seo_tags %>` in templates
4. **Canonical URLs** - Use `<%= canonical_tag %>`
5. **Submit to search engines** - Google Search Console

## Continuous Deployment

### With Git

1. Push code to GitHub/GitLab
2. Host connects to repository
3. Automatic builds on push
4. Site updates automatically

### Build Command

Most hosts need:

```bash
gem install jackdaw && jackdaw build
```

### Build Time

Jackdaw is fast:
- Small site (10 pages): ~0.1s
- Medium site (100 pages): ~0.5s  
- Large site (600 pages): ~0.9s

## Rollback

If something breaks:

**Netlify:**
```bash
netlify rollback
```

**Vercel:**
- Use dashboard to rollback deployment

**Git-based:**
```bash
git revert HEAD
git push
```

## Monitoring

Check your deployed site:

```bash
# Status
curl -I https://example.com

# Performance
curl -w "@curl-format.txt" -o /dev/null -s https://example.com
```

**curl-format.txt:**
```
time_total: %{time_total}s
```

## Troubleshooting

**Build fails:**
- Check Ruby version (need 4.0+)
- Install bundler if using Gemfile
- Check build logs for errors

**404 errors:**
- Verify public/ has files
- Check deployment directory setting
- Ensure build completed successfully

**Assets not loading:**
- Use absolute paths: `/css/style.css`
- Check asset file locations
- Verify asset directory deployed

**Slow build:**
- Use incremental builds (default)
- Cache dependencies
- Check build machine specs
