# frozen_string_literal: true

RSpec.describe Jackdaw::Project do
  let(:site_dir) { create_test_site }
  let(:project) { described_class.new(site_dir) }

  describe '#initialize' do
    it 'sets the root directory' do
      expect(project.root).to eq(site_dir)
    end
  end

  describe '#site_dir' do
    it 'returns site directory path' do
      expect(project.site_dir).to eq(File.join(site_dir, 'site'))
    end
  end

  describe '#src_dir' do
    it 'returns source content directory path' do
      expect(project.src_dir).to eq(File.join(site_dir, 'site/src'))
    end
  end

  describe '#templates_dir' do
    it 'returns templates directory path' do
      expect(project.templates_dir).to eq(File.join(site_dir, 'site/templates'))
    end
  end

  describe '#assets_dir' do
    it 'returns assets directory path' do
      expect(project.assets_dir).to eq(File.join(site_dir, 'site/assets'))
    end
  end

  describe '#output_dir' do
    it 'returns public output directory path' do
      expect(project.output_dir).to eq(File.join(site_dir, 'public'))
    end
  end

  describe '#exists?' do
    context 'when site directory exists' do
      it 'returns true' do
        expect(project.exists?).to be true
      end
    end

    context 'when site directory does not exist' do
      it 'returns false' do
        non_existent = described_class.new('/tmp/does-not-exist.site')
        expect(non_existent.exists?).to be false
      end
    end
  end

  describe '#create!' do
    let(:new_site_dir) { File.join(Dir.mktmpdir, 'new-site.site') }
    let(:new_project) { described_class.new(new_site_dir) }

    after do
      FileUtils.rm_rf(new_site_dir) if Dir.exist?(new_site_dir)
    end

    it 'creates site directory structure' do
      new_project.create!

      expect(Dir.exist?(new_site_dir)).to be true
      expect(Dir.exist?(File.join(new_site_dir, 'site'))).to be true
      expect(Dir.exist?(File.join(new_site_dir, 'site/src'))).to be true
      expect(Dir.exist?(File.join(new_site_dir, 'site/templates'))).to be true
      expect(Dir.exist?(File.join(new_site_dir, 'site/assets'))).to be true
      expect(Dir.exist?(File.join(new_site_dir, 'public'))).to be true
    end
  end
end
