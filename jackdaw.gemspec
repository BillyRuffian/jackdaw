# frozen_string_literal: true

require_relative 'lib/jackdaw/version'

Gem::Specification.new do |spec|
  spec.name = 'jackdaw'
  spec.version = Jackdaw::VERSION
  spec.authors = ['Nigel Brookes-Thomas']
  spec.email = ['nigel@brookes-thomas.co.uk']

  spec.summary = 'Lightning-fast static site generator with convention over configuration'
  spec.description = 'Jackdaw is a minimal, fast static site generator that emphasizes speed, ' \
                     'incremental builds, and developer experience. Build 600 files in under 1 second with ' \
                     'parallel processing, live reload, and zero configuration required.'
  spec.homepage = 'https://github.com/BilyRuffian/jackdaw'
  spec.required_ruby_version = '>= 4.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/yourusername/jackdaw'
  spec.metadata['changelog_uri'] = 'https://github.com/yourusername/jackdaw/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'kramdown', '~> 2.4'
  spec.add_dependency 'kramdown-parser-gfm', '~> 1.1'
  spec.add_dependency 'listen', '~> 3.9'
  spec.add_dependency 'parallel', '~> 1.24'
  spec.add_dependency 'puma', '~> 6.4'
  spec.add_dependency 'rack', '~> 3.0'
  spec.add_dependency 'rouge', '~> 4.2'
  spec.add_dependency 'thor', '~> 1.3'
end
