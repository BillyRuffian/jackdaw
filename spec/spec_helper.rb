# frozen_string_literal: true

require 'jackdaw'
require 'tmpdir'
require 'fileutils'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up test directories after each example
  config.after(:each) do
    @test_dirs&.each do |dir|
      FileUtils.rm_rf(dir) if Dir.exist?(dir)
    end
  end
end

# Helper methods for creating test fixtures
module SpecHelpers
  def create_test_site(name: 'test-site')
    dir = Dir.mktmpdir("#{name}-")
    (@test_dirs ||= []) << dir

    site_dir = File.join(dir, "#{name}.site")
    Dir.mkdir(site_dir)

    # Create site structure
    %w[site site/src site/templates site/assets public].each do |subdir|
      Dir.mkdir(File.join(site_dir, subdir))
    end

    site_dir
  end

  def create_content_file(site_dir, filename, content)
    path = File.join(site_dir, 'site/src', filename)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  def create_template_file(site_dir, filename, content)
    path = File.join(site_dir, 'site/templates', filename)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  def create_asset_file(site_dir, filename, content = '')
    path = File.join(site_dir, 'site/assets', filename)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end
