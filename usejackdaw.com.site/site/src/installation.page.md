# Installation

## Requirements

- Ruby 4.0 or later
- Bundler (recommended)

## Install from RubyGems

The easiest way to install Jackdaw:

```bash
gem install jackdaw
```

Verify the installation:

```bash
jackdaw version
```

## Using Bundler

Add to your `Gemfile`:

```ruby
gem 'jackdaw'
```

Then install:

```bash
bundle install
```

## From Source

Clone the repository and build:

```bash
git clone https://github.com/yourusername/jackdaw.git
cd jackdaw
bundle install
gem build jackdaw.gemspec
gem install jackdaw-1.0.0.gem
```

## Dependencies

Jackdaw automatically installs these dependencies:

- **kramdown** (~> 2.4) - Markdown parsing
- **kramdown-parser-gfm** (~> 1.1) - GitHub-flavored Markdown
- **rouge** (~> 4.2) - Syntax highlighting
- **thor** (~> 1.3) - CLI framework
- **parallel** (~> 1.24) - Parallel processing
- **puma** (~> 6.4) - Development server
- **rack** (~> 3.0) - Web server interface
- **listen** (~> 3.9) - File watching

## Next Steps

Once installed, [create your first site →](/getting-started.html)
