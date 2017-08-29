require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::ExtensionPath do
  
  let(:ep) { Radiant::ExtensionPath.from_path(File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic")) }
  let(:gem_ep) { Radiant::ExtensionPath.from_path("/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0") }
  let(:git_ep) { Radiant::ExtensionPath.from_path("/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae") }

  describe "recording a vendored extension" do
    it "should parse the name of the extension from the path" do
      expect(ep.name).to eq('basic')
    end
    
    it "should return the basename of the extension file that should be required" do
      expect(ep.required).to eq(File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic/basic_extension"))
    end
    
    it "should return the extension path" do
      expect(ep.path).to eq(File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic"))
      expect(ep.to_s).to eq(File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic"))
    end
    
    it "should store the extension path object" do
      expect(Radiant::ExtensionPath.find(:basic).path).to eq(ep.path)
      expect(Radiant::ExtensionPath.for(:basic)).to eq(File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/basic"))
    end
  end

  describe "recording a gem extension" do
    it "should parse the name of the extension from the gem path" do
      expect(gem_ep.name).to eq('gem_ext')
    end

    it "should return the name of the extension file" do
      expect(gem_ep.required).to eq("/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0/gem_ext_extension")
    end

    it "should return the extension path" do
      expect(gem_ep.path).to eq("/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0")
      expect(gem_ep.to_s).to eq("/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0")
    end

    it "should store the extension path object" do
      expect(Radiant::ExtensionPath.find(:gem_ext).path).to eq(gem_ep.path)
      expect(Radiant::ExtensionPath.for(:gem_ext)).to eq("/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0")
    end
  end

  describe "recording a git-repository extension" do
    it "should parse the name of the extension from the gem path" do
      expect(git_ep.name).to eq('git_ext')
    end

    it "should return the name of the extension file" do
      expect(git_ep.required).to eq("/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae/git_ext_extension")
    end

    it "should return the extension path" do
      expect(git_ep.path).to eq("/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae")
      expect(git_ep.to_s).to eq("/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae")
    end

    it "should store the extension path object" do
      expect(Radiant::ExtensionPath.find(:git_ext).path).to eq(git_ep.path)
      expect(Radiant::ExtensionPath.for(:git_ext)).to eq("/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae")
    end
  end

  describe "looking for load paths" do
    before do
      Radiant::ExtensionPath.clear_paths!
      @configuration = double("configuration")
      allow(Radiant).to receive(:configuration).and_return(@configuration)
      @extensions = %w{basic overriding}
      @extensions.each do |ext|
        Radiant::ExtensionPath.from_path(File.expand_path("#{RADIANT_ROOT}/test/fixtures/extensions/#{ext}"))
      end
      allow(@configuration).to receive(:enabled_extensions).and_return(@extensions.map(&:to_sym))
    end
    
    describe "in an individual extension root" do
      [:load_paths, :plugin_paths, :controller_paths, :view_paths, :metal_paths, :locale_paths].each do |meth|
        it "should respond to #{meth}" do
          ep = Radiant::ExtensionPath.find(:basic)
          expect(ep).to respond_to(meth)
        end
      end
      
      it "should report paths that exist" do
        expect(File.directory?(Radiant::ExtensionPath.find(:basic).plugin_paths)).to be true
        expect(File.directory?(Radiant::ExtensionPath.find(:basic).metal_paths)).to be true
        expect(File.directory?(Radiant::ExtensionPath.find(:basic).model_paths)).to be true
        expect(File.directory?(Radiant::ExtensionPath.find(:basic).view_paths)).to be true
        expect(File.directory?(Radiant::ExtensionPath.find(:overriding).plugin_paths)).to be true
        expect(File.directory?(Radiant::ExtensionPath.find(:overriding).metal_paths)).to be true
        expect(File.directory?(Radiant::ExtensionPath.find(:overriding).view_paths)).to be true
      end
      it "should not report paths that don't exist" do
        expect(Radiant::ExtensionPath.find(:basic).locale_paths).to be_nil
        expect(Radiant::ExtensionPath.find(:overriding).controller_paths).to be_nil
        expect(Radiant::ExtensionPath.find(:overriding).model_paths).to be_nil
        expect(Radiant::ExtensionPath.find(:overriding).locale_paths).to be_nil
      end
    end

    describe "across the set of enabled extensions" do
      [:load_paths, :plugin_paths, :controller_paths, :view_paths, :metal_paths, :locale_paths].each do |meth|
        it "should return collected #{meth}" do
          expect(Radiant::ExtensionPath).to respond_to(meth)
          expect(Radiant::ExtensionPath.send(meth)).to be_instance_of(Array)
          expect(Radiant::ExtensionPath.send(meth).all? { |f| File.directory?(f) }).to be true
        end
      end

      it "should return view_paths in inverse load order" do
        expect(Radiant::ExtensionPath.view_paths).to eq([
         "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/views",
         "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/views"
        ])
      end

      it "should return metal_paths in inverse load order" do
        expect(Radiant::ExtensionPath.metal_paths).to eq([
         "#{RADIANT_ROOT}/test/fixtures/extensions/overriding/app/metal",
         "#{RADIANT_ROOT}/test/fixtures/extensions/basic/app/metal"
        ])
      end
    end

  end

end