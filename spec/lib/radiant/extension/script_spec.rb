require 'radiant/extension/script'

describe "Radiant::Extension::Script" do
  it "should determine which subscript to run" do
    expect(Radiant::Extension::Script::Install).to receive(:new)
    Radiant::Extension::Script.execute ['install']

    expect(Radiant::Extension::Script::Uninstall).to receive(:new)
    Radiant::Extension::Script.execute ['uninstall']
  end

  it "should pass the command-line args to the subscript" do
    expect(Radiant::Extension::Script::Install).to receive(:new).with(['page_attachments'])
    Radiant::Extension::Script.execute ['install', 'page_attachments']
  end

  it "should run the help command when no arguments are given" do
    expect(Radiant::Extension::Script::Help).to receive(:new)
    Radiant::Extension::Script.execute []
  end

  it "should run the help for a given command when it fails" do
    error_message = "You must specify an extension to install."
    expect(Radiant::Extension::Script::Install).to receive(:new).and_raise(ArgumentError.new(error_message))
    expect(Radiant::Extension::Script).to receive(:puts).with(error_message)
    expect(Radiant::Extension::Script::Help).to receive(:new).with(['install'])
    Radiant::Extension::Script.execute ['install']
  end
end

describe "Radiant::Extension::Script::Util" do
  include Radiant::Extension::Script::Util

  it "should determine an extension name from a camelized string" do
    expect(to_extension_name("PageAttachments")).to eq('page_attachments')
  end

  it "should determine an extension name from a hyphened name" do
    expect(to_extension_name("page-attachments")).to eq('page_attachments')
  end

  it "should determine an extension name from an underscored name" do
    expect(to_extension_name("page_attachments")).to eq('page_attachments')
  end

  it "should determine extension paths" do
    # Bad coupling, but will work by default
    expect(extension_paths).to be_kind_of(Array)
    expect(extension_paths).to include("#{RADIANT_ROOT}/test/fixtures/extensions/basic")
  end

  it "should determine whether an extension is installed" do
    # Bad coupling, but will work by default
    @script = double('script action')
    @script.extend Radiant::Extension::Script::Util
    @script.extension_name = 'basic'
    expect(@script).to be_installed
  end

  it "should determine whether an extension is not installed" do
    @script = double('script action',extension_paths: ['/path/to/extension/html_tags'])
    @script.extend Radiant::Extension::Script::Util
    @script.extension_name = 'tags'
    expect(@script).not_to be_installed
  end

  it "should determine whether an extension is installed" do
    @script = double('script action',extension_paths: ['tags'])
    @script.extend Radiant::Extension::Script::Util
    @script.extension_name = 'tags'
    expect(@script).to be_installed
  end

  it "should determine whether an extension is installed" do
    @script = double('script action',extension_paths: ['/path/to/extension/tags'])
    @script.extend Radiant::Extension::Script::Util
    @script.extension_name = 'tags'
    expect(@script).to be_installed
  end

  it "should determine whether an extension is installed on windows system" do
    @script = double('script action',extension_paths: ['c:\path\to\extension\tags'])
    @script.extend Radiant::Extension::Script::Util
    @script.extension_name = 'tags'
    expect(@script).to be_installed
  end

  it "should load all extensions from the web service" do
    expect(Registry::Extension).to receive(:find).with(:all).and_return([1,2,3])
    expect(load_extensions).to eq([1,2,3])
  end

  it "should find an extension of the given name from the web service" do
    @ext_double = double("Extension", name: 'page_attachments')
    should_receive(:load_extensions).and_return([@ext_double])
    self.extension_name = 'page_attachments'
    expect(find_extension).to eq(@ext_double)
  end
end

describe "Radiant::Extension::Script::Install" do

  before :each do
    @extension = double('Extension', install: true, name: 'page_attachments')
    allow(Registry::Extension).to receive(:find).and_return([@extension])
  end

  it "should read the extension name from the command line" do
    @install = Radiant::Extension::Script::Install.new ['page_attachments']
    expect(@install.extension_name).to eq('page_attachments')
  end

  it "should attempt to find the extension and install it" do
    expect(@extension).to receive(:install).and_return(true)
    @install = Radiant::Extension::Script::Install.new ['page_attachments']
  end

  it "should fail if the extension is not found" do
    expect { Radiant::Extension::Script::Install.new ['non_existent_extension'] }.to raise_error
  end

  it "should fail if an extension name is not given" do
    expect { Radiant::Extension::Script::Install.new []}.to raise_error
  end
end

describe "Radiant::Extension::Script::Uninstall" do
  before :each do
    @extension = double('Extension', uninstall: true, name: 'basic')
    allow(Registry::Extension).to receive(:find).and_return([@extension])
  end

  it "should read the extension name from the command line" do
    @uninstall = Radiant::Extension::Script::Uninstall.new ['basic']
    expect(@uninstall.extension_name).to eq('basic')
  end

  it "should attempt to find the extension and uninstall it" do
    expect(@extension).to receive(:uninstall).and_return(true)
    @uninstall = Radiant::Extension::Script::Uninstall.new ['basic']
  end

  it "should fail if an extension name is not given" do
    expect { Radiant::Extension::Script::Uninstall.new []}.to raise_error
  end
end

describe "Radiant::Extension::Script::Info" do
  before :each do
    @extension = double('Extension', uninstall: true, name: 'archive', inspect: '')
    allow(Registry::Extension).to receive(:find).and_return([@extension])
  end

  it "should read the extension name from the command line" do
    @info = Radiant::Extension::Script::Info.new ['archive']
    expect(@info.extension_name).to eq('archive')
  end

  it "should attempt to find the extension and display its info" do
    expect(@extension).to receive(:inspect).and_return('')
    @info = Radiant::Extension::Script::Info.new ['archive']
  end

  it "should fail if an extension name is not given" do
    expect { Radiant::Extension::Script::Info.new []}.to raise_error
  end
end

describe "Radiant::Extension::Script::Help" do
  it "should display the general help message when no arguments are given" do
    expect($stdout).to receive(:puts).with(%r{Usage:   script/extension command \[arguments\]})
    Radiant::Extension::Script::Help.new
  end

  it "should display the general help message when the 'help' command is specified" do
    expect($stdout).to receive(:puts).with(%r{Usage:   script/extension command \[arguments\]})
    Radiant::Extension::Script::Help.new ['help']
  end

  it "should display the general help message when an invalid command is given" do
    expect($stdout).to receive(:puts).with(%r{Usage:   script/extension command \[arguments\]})
    Radiant::Extension::Script::Help.new ['foo']
  end

  it "should display the install help message" do
    expect($stdout).to receive(:puts).with(%r{Usage:    script/extension install extension_name})
    Radiant::Extension::Script::Help.new ['install']
  end

  it "should display the uninstall help message" do
    expect($stdout).to receive(:puts).with(%r{Usage:    script/extension uninstall extension_name})
    Radiant::Extension::Script::Help.new ['uninstall']
  end

  it "should display the info help message" do
    expect($stdout).to receive(:puts).with(%r{Usage:    script/extension info extension_name})
    Radiant::Extension::Script::Help.new ['info']
  end
end

describe "Registry::Action" do
  before :each do
    @action = Registry::Action.new
  end

  it "should shell out with the specified rake task if it exists" do
    rails_gemspec = Bundler.load.specs.find{|s| s.name == 'rails' }
    rake_file = File.join(rails_gemspec.full_gem_path, 'lib', 'tasks', 'misc.rake')
    load rake_file
    expect(@action).to receive(:`).with("rake secret RAILS_ENV=#{RAILS_ENV}")
    @action.rake('secret')
  end

  it "should not shell out with the specified rake task if it does not exist" do
    expect(@action).not_to receive(:`).with("rake non_existant_task RAILS_ENV=#{RAILS_ENV}")
    @action.rake('non_existant_task')
  end
end

describe "Registry::Installer" do
  before :each do
    @installer = Registry::Installer.new('http://localhost/', 'example')
  end

  it "should set the name and url of the extension" do
    expect(@installer.url).to eq('http://localhost/')
    expect(@installer.name).to eq('example')
  end

  it "should install by copying, migrating and updating" do
    expect(@installer).to receive(:copy_to_vendor_extensions)
    expect(@installer).to receive(:migrate)
    expect(@installer).to receive(:update)
    @installer.install
  end

  it "should copy the extension to vendor/extensions" do
    @installer.path = "/tmp"
    expect(FileUtils).to receive(:cp_r).with('/tmp', "#{RAILS_ROOT}/vendor/extensions/example")
    expect(FileUtils).to receive(:rm_r).with('/tmp')
    @installer.copy_to_vendor_extensions
  end

  it "should run the rake migrate task" do
    expect(@installer).to receive(:rake).with('radiant:extensions:example:migrate')
    @installer.migrate
  end

  it "should run the rake update task" do
    expect(@installer).to receive(:rake).with('radiant:extensions:example:update')
    @installer.update
  end
end

describe "Registry::Uninstaller" do
  before :each do
    @extension = double('Extension', name: 'example')
    @uninstaller = Registry::Uninstaller.new(@extension)
  end

  it "should migrate down" do
    expect(@uninstaller).to receive(:rake).with("radiant:extensions:example:migrate VERSION=0")
    @uninstaller.migrate_down
  end

  it "should remove the extension directory" do
    expect(FileUtils).to receive(:rm_r).with("#{RAILS_ROOT}/vendor/extensions/example")
    @uninstaller.remove_extension_directory
  end

  it "should uninstall by migrating down and removing the directory" do
    expect(@uninstaller).to receive(:migrate_down)
    expect(@uninstaller).to receive(:remove_extension_directory)
    @uninstaller.uninstall
  end
end

describe "Registry::Checkout" do
  before :each do
    @extension = double("Extension", name: 'example', repository_url: 'http://localhost/')
    @checkout = Registry::Checkout.new(@extension)
    @methods = [:copy_to_vendor_extensions, :migrate, :update].each do |method|
      allow(@checkout).to receive(method).and_return(true)
    end
    allow(@checkout).to receive(:cd).and_yield
  end

  it "should set the name and url" do
    expect(@checkout.name).to eq('example')
    expect(@checkout.url).to eq('http://localhost/')
  end

  it "should defer the checkout command to concrete subclasses" do
    expect { @checkout.checkout_command }.to raise_error
  end

  it "should install by checking out the source and then proceeding with the normal installation" do
    @methods.each { |method|  expect(@checkout).to receive(method) }
    expect(@checkout).to receive(:checkout)
    @checkout.install
  end

  it "should checkout the source" do
    allow(@checkout).to receive(:checkout_command).and_return('echo')
    expect(@checkout).to receive(:cd)
    expect(@checkout).to receive(:system).with('echo')
    @checkout.checkout
    expect(@checkout.path).not_to be_nil
    expect(@checkout.path).to match(/example/)
  end
end

describe "Registry::Download" do
  before :each do
    @extension = double("Extension", name: 'example', download_url: 'http://localhost/example.pkg')
    @download = Registry::Download.new(@extension)
    @methods = [:copy_to_vendor_extensions, :migrate, :update].each do |method|
      allow(@download).to receive(method).and_return(true)
    end
  end

  it "should set the name and url" do
    expect(@download.name).to eq('example')
    expect(@download.url).to eq('http://localhost/example.pkg')
  end

  it "should defer the unpack command to concrete subclasses" do
    expect { @download.unpack }.to raise_error
  end

  it "should install by downloading and unpacking and then proceeding with the normal installation" do
    @methods.each { |method|  expect(@download).to receive(method) }
    expect(@download).to receive(:download)
    expect(@download).to receive(:unpack)
    @download.install
  end

  it "should determine the filename" do
    expect(@download.filename).to eq('example.pkg')
  end

  it "should download the file" do
    @file = double('file')
    expect(File).to receive(:open).with(/example\.pkg/, 'w').and_yield(@file)
    expect(@download).to receive(:open).and_return(StringIO.new('test'))
    expect(@file).to receive(:write).with('test')
    @download.download
  end
end

describe "Registry::Git" do
  before :each do
    @extension = double("Extension", name: 'example', repository_url: 'http://localhost/')
    @git = Registry::Git.new(@extension)
    allow(@git).to receive(:system)
    allow(@git).to receive(:cd).and_yield
  end

  describe "when the Radiant project is not stored in git" do
    before :each do
      allow(File).to receive(:directory?).with(".git").and_return(false)
    end

    it "should use git to clone the repository" do
      expect(@git.checkout_command).to eq('git clone http://localhost/ example')
    end

    it "should initialize and update submodules" do
      allow(Dir).to receive(:tmpdir).and_return('/tmp')
      expect(@git).to receive(:cd).with("/tmp").ordered
      expect(@git).to receive(:system).with("git clone http://localhost/ example").ordered
      expect(@git).to receive(:cd).with("/tmp/example").ordered
      expect(@git).to receive(:system).with("git submodule init && git submodule update").ordered
      @git.checkout
    end

    it "should copy the extension to vendor/extensions" do
      @git.path = "/tmp"
      expect(@git).to receive(:cp_r).with('/tmp', "#{RAILS_ROOT}/vendor/extensions/example")
      expect(@git).to receive(:rm_r).with('/tmp')
      @git.copy_to_vendor_extensions
    end
  end

  describe "when the Radiant project is stored in git" do
    before :each do
      allow(File).to receive(:directory?).with(".git").and_return(true)
    end

    it "should add the extension as a submodule and initialize and update its submodules" do
      expect(@git).to receive(:system).with("git submodule add http://localhost/ vendor/extensions/example").ordered
      expect(@git).to receive(:cd).with("vendor/extensions/example").ordered
      expect(@git).to receive(:system).with("git submodule init && git submodule update").ordered
      @git.checkout
    end

    it "should not copy the extension" do
      expect(@git).not_to receive(:cp_r)
      expect(@git).not_to receive(:rm_r)
      @git.copy_to_vendor_extensions
    end
  end
end

describe "Registry::Subversion" do
  before :each do
    @extension = double("Extension", name: 'example', repository_url: 'http://localhost/')
    @svn = Registry::Subversion.new(@extension)
  end

  it "should use svn to checkout the repository" do
    expect(@svn.checkout_command).to eq('svn checkout http://localhost/ example')
  end
end

describe "Registry::Gem" do
  before :each do
    @extension = double("Extension", name: 'example', download_url: 'http://localhost/example-1.0.0.gem')
    @gem = Registry::Gem.new(@extension)
  end

  it "should download the gem and install it if it is not already installed" do
    expect(@gem).to receive(:gem).and_raise(::Gem::LoadError.new)
    @file = double('file')
    expect(File).to receive(:open).with(/example-1.0.0\.gem/, 'w').and_yield(@file)
    expect(@gem).to receive(:open).and_return(StringIO.new('test'))
    expect(@file).to receive(:write).with('test')
    expect(@gem).to receive(:`).with("gem install example")
    @gem.download
  end

  it "should not download the gem if it is already installed" do
    expect(@gem).to receive(:gem).and_return(true)
    expect(File).not_to receive(:open)
    expect(@gem).not_to receive(:open)
    expect(@gem).not_to receive(:`)
    @gem.download
  end

  it "should unpack the gem and capture the path" do
    expect(@gem).to receive(:`).with(/gem unpack example/).and_return("Unpacked gem: '/tmp/example-1.0.0'")
    @gem.unpack
    expect(@gem.path).to eq('/tmp/example-1.0.0')
  end
end

describe "Registry::Tarball" do
  before :each do
    @extension = double("Extension", name: 'example', download_url: 'http://localhost/example-1.0.0.tar')
    @tar = Registry::Tarball.new(@extension)
  end

  it "should unpack the tarball without compression" do
    expect(@tar).to receive(:`).with(/tar xvf example.tar/).and_return('example-1.0.0/example_extension.rb\n')
    @tar.unpack
    expect(@tar.path).to match(/example-1\.0\.0$/)
  end
end

describe "Registry::Gzip" do
  before :each do
    @extension = double("Extension", name: 'example', download_url: 'http://localhost/example-1.0.0.tar.gz')
    @gzip = Registry::Gzip.new(@extension)
  end

  it "should unpack the archive with compression" do
    expect(@gzip).to receive(:system).with(/gunzip example.tar.gz/)
    expect(@gzip).to receive(:`).with(/tar xvf example.tar/).and_return('example-1.0.0/example_extension.rb\n')
    @gzip.unpack
    expect(@gzip.path).to match(/example-1\.0\.0$/)
  end
end

describe "Registry::Bzip2" do
  before :each do
    @extension = double("Extension", name: 'example', download_url: 'http://localhost/example-1.0.0.tar.bz2')
    @gzip = Registry::Bzip2.new(@extension)
  end

  it "should unpack the archive with compression" do
    expect(@gzip).to receive(:system).with(/bunzip2 example.tar.bz2/)
    expect(@gzip).to receive(:`).with(/tar xvf example.tar/).and_return('example-1.0.0/example_extension.rb\n')
    @gzip.unpack
    expect(@gzip.path).to match(/example-1\.0\.0$/)
  end
end


describe "Registry::Zip" do
  before :each do
    @extension = double("Extension", name: 'example', download_url: 'http://localhost/example-1.0.0.zip')
    @zip = Registry::Zip.new(@extension)
  end

  it "should unpack the zip" do
    expect(@zip).to receive(:`).with(/unzip example-1.0.0.zip -d example/).and_return('')
    @zip.unpack
    expect(@zip.path).to match(/example$/)
  end
end
