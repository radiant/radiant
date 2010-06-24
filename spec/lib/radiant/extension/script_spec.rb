require File.dirname(__FILE__) + "/../../../spec_helper"
require 'radiant/extension/script'

describe "Radiant::Extension::Script" do
  it "should determine which subscript to run" do
    Radiant::Extension::Script::Install.should_receive(:new)
    Radiant::Extension::Script.execute ['install']

    Radiant::Extension::Script::Uninstall.should_receive(:new)
    Radiant::Extension::Script.execute ['uninstall']
  end

  it "should pass the command-line args to the subscript" do
    Radiant::Extension::Script::Install.should_receive(:new).with(['page_attachments'])
    Radiant::Extension::Script.execute ['install', 'page_attachments']
  end

  it "should run the help command when no arguments are given" do
    Radiant::Extension::Script::Help.should_receive(:new)
    Radiant::Extension::Script.execute []
  end

  it "should run the help for a given command when it fails" do
    error_message = "You must specify an extension to install."
    Radiant::Extension::Script::Install.should_receive(:new).and_raise(ArgumentError.new(error_message))
    Radiant::Extension::Script.should_receive(:puts).with(error_message)
    Radiant::Extension::Script::Help.should_receive(:new).with(['install'])
    Radiant::Extension::Script.execute ['install']
  end
end

describe "Radiant::Extension::Script::Util" do
  include Radiant::Extension::Script::Util

  it "should determine an extension name from a camelized string" do
    to_extension_name("PageAttachments").should == 'page_attachments'
  end

  it "should determine an extension name from a hyphened name" do
    to_extension_name("page-attachments").should == 'page_attachments'
  end

  it "should determine an extension name from an underscored name" do
    to_extension_name("page_attachments").should == 'page_attachments'
  end

  it "should determine extension paths" do
    # Bad coupling, but will work by default
    extension_paths.should be_kind_of(Array)
    extension_paths.should include("#{RADIANT_ROOT}/vendor/extensions/archive")
  end

  it "should determine whether an extension is installed" do
    # Bad coupling, but will work by default
    @script = mock('script action')
    @script.extend Radiant::Extension::Script::Util
    @script.extension_name = 'archive'
    @script.should be_installed
  end

  it "should load all extensions from the web service" do
    Registry::Extension.should_receive(:find).with(:all).and_return([1,2,3])
    load_extensions.should == [1,2,3]
  end

  it "should find an extension of the given name from the web service" do
    @ext_mock = mock("Extension", :name => 'page_attachments')
    should_receive(:load_extensions).and_return([@ext_mock])
    self.extension_name = 'page_attachments'
    find_extension.should == @ext_mock
  end
end

describe "Radiant::Extension::Script::Install" do

  before :each do
    @extension = mock('Extension', :install => true, :name => 'page_attachments')
    Registry::Extension.stub!(:find).and_return([@extension])
  end

  it "should read the extension name from the command line" do
    @install = Radiant::Extension::Script::Install.new ['page_attachments']
    @install.extension_name.should == 'page_attachments'
  end

  it "should attempt to find the extension and install it" do
    @extension.should_receive(:install).and_return(true)
    @install = Radiant::Extension::Script::Install.new ['page_attachments']
  end

  it "should fail if the extension is not found" do
    lambda { Radiant::Extension::Script::Install.new ['non_existent_extension'] }.should raise_error
  end

  it "should fail if an extension name is not given" do
    lambda { Radiant::Extension::Script::Install.new []}.should raise_error
  end
end

describe "Radiant::Extension::Script::Uninstall" do

  before :each do
    @extension = mock('Extension', :uninstall => true, :name => 'archive')
    Registry::Extension.stub!(:find).and_return([@extension])
  end

  it "should read the extension name from the command line" do
    @uninstall = Radiant::Extension::Script::Uninstall.new ['archive']
    @uninstall.extension_name.should == 'archive'
  end

  it "should attempt to find the extension and uninstall it" do
    @extension.should_receive(:uninstall).and_return(true)
    @uninstall = Radiant::Extension::Script::Uninstall.new ['archive']
  end

  it "should fail if an extension name is not given" do
    lambda { Radiant::Extension::Script::Uninstall.new []}.should raise_error
  end
end

describe "Radiant::Extension::Script::Info" do
  before :each do
    @extension = mock('Extension', :uninstall => true, :name => 'archive', :inspect => '')
    Registry::Extension.stub!(:find).and_return([@extension])
  end

  it "should read the extension name from the command line" do
    @info = Radiant::Extension::Script::Info.new ['archive']
    @info.extension_name.should == 'archive'
  end

  it "should attempt to find the extension and display its info" do
    @extension.should_receive(:inspect).and_return('')
    @info = Radiant::Extension::Script::Info.new ['archive']
  end

  it "should fail if an extension name is not given" do
    lambda { Radiant::Extension::Script::Info.new []}.should raise_error
  end
end

describe "Radiant::Extension::Script::Help" do
  it "should display the general help message when no arguments are given" do
    $stdout.should_receive(:puts).with(%r{Usage:   script/extension command \[arguments\]})
    Radiant::Extension::Script::Help.new
  end

  it "should display the general help message when the 'help' command is specified" do
    $stdout.should_receive(:puts).with(%r{Usage:   script/extension command \[arguments\]})
    Radiant::Extension::Script::Help.new ['help']
  end

  it "should display the general help message when an invalid command is given" do
    $stdout.should_receive(:puts).with(%r{Usage:   script/extension command \[arguments\]})
    Radiant::Extension::Script::Help.new ['foo']
  end

  it "should display the install help message" do
    $stdout.should_receive(:puts).with(%r{Usage:    script/extension install extension_name})
    Radiant::Extension::Script::Help.new ['install']
  end

  it "should display the uninstall help message" do
    $stdout.should_receive(:puts).with(%r{Usage:    script/extension uninstall extension_name})
    Radiant::Extension::Script::Help.new ['uninstall']
  end

  it "should display the info help message" do
    $stdout.should_receive(:puts).with(%r{Usage:    script/extension info extension_name})
    Radiant::Extension::Script::Help.new ['info']
  end
end

describe "Registry::Action" do
  before :each do
    @action = Registry::Action.new
  end

  it "should shell out with the specified rake task if it exists" do
    rake_file = File.join(RADIANT_ROOT, 'vendor', 'rails', 'railties', 'lib', 'tasks', 'misc.rake')
    load rake_file
    @action.should_receive(:`).with("rake secret RAILS_ENV=#{RAILS_ENV}")
    @action.rake('secret')
  end

  it "should not shell out with the specified rake task if it does not exist" do
    @action.should_not_receive(:`).with("rake non_existant_task RAILS_ENV=#{RAILS_ENV}")
    @action.rake('non_existant_task')
  end
end

describe "Registry::Installer" do
  before :each do
    @installer = Registry::Installer.new('http://localhost/', 'example')
  end

  it "should set the name and url of the extension" do
    @installer.url.should == 'http://localhost/'
    @installer.name.should == 'example'
  end

  it "should install by copying, migrating and updating" do
    @installer.should_receive(:copy_to_vendor_extensions)
    @installer.should_receive(:migrate)
    @installer.should_receive(:update)
    @installer.install
  end

  it "should copy the extension to vendor/extensions" do
    @installer.path = "/tmp"
    FileUtils.should_receive(:cp_r).with('/tmp', "#{RAILS_ROOT}/vendor/extensions/example")
    FileUtils.should_receive(:rm_r).with('/tmp')
    @installer.copy_to_vendor_extensions
  end

  it "should run the rake migrate task" do
    @installer.should_receive(:rake).with('radiant:extensions:example:migrate')
    @installer.migrate
  end

  it "should run the rake update task" do
    @installer.should_receive(:rake).with('radiant:extensions:example:update')
    @installer.update
  end
end

describe "Registry::Uninstaller" do
  before :each do
    @extension = mock('Extension', :name => 'example')
    @uninstaller = Registry::Uninstaller.new(@extension)
  end

  it "should migrate down" do
    @uninstaller.should_receive(:rake).with("radiant:extensions:example:migrate VERSION=0")
    @uninstaller.migrate_down
  end

  it "should remove the extension directory" do
    FileUtils.should_receive(:rm_r).with("#{RAILS_ROOT}/vendor/extensions/example")
    @uninstaller.remove_extension_directory
  end

  it "should uninstall by migrating down and removing the directory" do
    @uninstaller.should_receive(:migrate_down)
    @uninstaller.should_receive(:remove_extension_directory)
    @uninstaller.uninstall
  end
end

describe "Registry::Checkout" do
  before :each do
    @extension = mock("Extension", :name => 'example', :repository_url => 'http://localhost/')
    @checkout = Registry::Checkout.new(@extension)
    @methods = [:copy_to_vendor_extensions, :migrate, :update].each do |method|
      @checkout.stub!(method).and_return(true)
    end
    @checkout.stub!(:cd).and_yield
  end

  it "should set the name and url" do
    @checkout.name.should == 'example'
    @checkout.url.should == 'http://localhost/'
  end

  it "should defer the checkout command to concrete subclasses" do
    lambda { @checkout.checkout_command }.should raise_error
  end

  it "should install by checking out the source and then proceeding with the normal installation" do
    @methods.each { |method|  @checkout.should_receive(method) }
    @checkout.should_receive(:checkout)
    @checkout.install
  end

  it "should checkout the source" do
    @checkout.stub!(:checkout_command).and_return('echo')
    @checkout.should_receive(:cd)
    @checkout.should_receive(:system).with('echo')
    @checkout.checkout
    @checkout.path.should_not be_nil
    @checkout.path.should =~ /example/
  end
end

describe "Registry::Download" do
  before :each do
    @extension = mock("Extension", :name => 'example', :download_url => 'http://localhost/example.pkg')
    @download = Registry::Download.new(@extension)
    @methods = [:copy_to_vendor_extensions, :migrate, :update].each do |method|
      @download.stub!(method).and_return(true)
    end
  end

  it "should set the name and url" do
    @download.name.should == 'example'
    @download.url.should == 'http://localhost/example.pkg'
  end

  it "should defer the unpack command to concrete subclasses" do
    lambda { @download.unpack }.should raise_error
  end

  it "should install by downloading and unpacking and then proceeding with the normal installation" do
    @methods.each { |method|  @download.should_receive(method) }
    @download.should_receive(:download)
    @download.should_receive(:unpack)
    @download.install
  end

  it "should determine the filename" do
    @download.filename.should == 'example.pkg'
  end

  it "should download the file" do
    @file = mock('file')
    File.should_receive(:open).with(/example\.pkg/, 'w').and_yield(@file)
    @download.should_receive(:open).and_return(StringIO.new('test'))
    @file.should_receive(:write).with('test')
    @download.download
  end
end

describe "Registry::Git" do
  before :each do
    @extension = mock("Extension", :name => 'example', :repository_url => 'http://localhost/')
    @git = Registry::Git.new(@extension)
    @git.stub!(:system)
    @git.stub!(:cd).and_yield
  end

  describe "when the Radiant project is not stored in git" do
    before :each do
      File.stub!(:directory?).with(".git").and_return(false)
    end

    it "should use git to clone the repository" do
      @git.checkout_command.should == 'git clone http://localhost/ example'
    end

    it "should initialize and update submodules" do
      Dir.stub!(:tmpdir).and_return('/tmp')
      @git.should_receive(:cd).with("/tmp").ordered
      @git.should_receive(:system).with("git clone http://localhost/ example").ordered
      @git.should_receive(:cd).with("/tmp/example").ordered
      @git.should_receive(:system).with("git submodule init && git submodule update").ordered
      @git.checkout
    end

    it "should copy the extension to vendor/extensions" do
      @git.path = "/tmp"
      @git.should_receive(:cp_r).with('/tmp', "#{RAILS_ROOT}/vendor/extensions/example")
      @git.should_receive(:rm_r).with('/tmp')
      @git.copy_to_vendor_extensions
    end
  end

  describe "when the Radiant project is stored in git" do
    before :each do
      File.stub!(:directory?).with(".git").and_return(true)
    end

    it "should add the extension as a submodule and initialize and update its submodules" do
      @git.should_receive(:system).with("git submodule add http://localhost/ vendor/extensions/example").ordered
      @git.should_receive(:cd).with("vendor/extensions/example").ordered
      @git.should_receive(:system).with("git submodule init && git submodule update").ordered
      @git.checkout
    end

    it "should not copy the extension" do
      @git.should_not_receive(:cp_r)
      @git.should_not_receive(:rm_r)
      @git.copy_to_vendor_extensions
    end
  end
end

describe "Registry::Subversion" do
  before :each do
    @extension = mock("Extension", :name => 'example', :repository_url => 'http://localhost/')
    @svn = Registry::Subversion.new(@extension)
  end

  it "should use svn to checkout the repository" do
    @svn.checkout_command.should == 'svn checkout http://localhost/ example'
  end
end

describe "Registry::Gem" do
  before :each do
    @extension = mock("Extension", :name => 'example', :download_url => 'http://localhost/example-1.0.0.gem')
    @gem = Registry::Gem.new(@extension)
  end

  it "should download the gem and install it if it is not already installed" do
    @gem.should_receive(:gem).and_raise(::Gem::LoadError.new)
    @file = mock('file')
    File.should_receive(:open).with(/example-1.0.0\.gem/, 'w').and_yield(@file)
    @gem.should_receive(:open).and_return(StringIO.new('test'))
    @file.should_receive(:write).with('test')
    @gem.should_receive(:`).with("gem install example")
    @gem.download
  end

  it "should not download the gem if it is already installed" do
    @gem.should_receive(:gem).and_return(true)
    File.should_not_receive(:open)
    @gem.should_not_receive(:open)
    @gem.should_not_receive(:`)
    @gem.download
  end

  it "should unpack the gem and capture the path" do
    @gem.should_receive(:`).with(/gem unpack example/).and_return("Unpacked gem: '/tmp/example-1.0.0'")
    @gem.unpack
    @gem.path.should == '/tmp/example-1.0.0'
  end
end

describe "Registry::Tarball" do
  before :each do
    @extension = mock("Extension", :name => 'example', :download_url => 'http://localhost/example-1.0.0.tar')
    @tar = Registry::Tarball.new(@extension)
  end

  it "should unpack the tarball without compression" do
    @tar.should_receive(:`).with(/tar xvf example.tar/).and_return('example-1.0.0/example_extension.rb\n')
    @tar.unpack
    @tar.path.should =~ /example-1\.0\.0$/
  end
end

describe "Registry::Gzip" do
  before :each do
    @extension = mock("Extension", :name => 'example', :download_url => 'http://localhost/example-1.0.0.tar.gz')
    @gzip = Registry::Gzip.new(@extension)
  end

  it "should unpack the archive with compression" do
    @gzip.should_receive(:system).with(/gunzip example.tar.gz/)
    @gzip.should_receive(:`).with(/tar xvf example.tar/).and_return('example-1.0.0/example_extension.rb\n')
    @gzip.unpack
    @gzip.path.should =~ /example-1\.0\.0$/
  end
end

describe "Registry::Bzip2" do
  before :each do
    @extension = mock("Extension", :name => 'example', :download_url => 'http://localhost/example-1.0.0.tar.bz2')
    @gzip = Registry::Bzip2.new(@extension)
  end

  it "should unpack the archive with compression" do
    @gzip.should_receive(:system).with(/bunzip2 example.tar.bz2/)
    @gzip.should_receive(:`).with(/tar xvf example.tar/).and_return('example-1.0.0/example_extension.rb\n')
    @gzip.unpack
    @gzip.path.should =~ /example-1\.0\.0$/
  end
end


describe "Registry::Zip" do
  before :each do
    @extension = mock("Extension", :name => 'example', :download_url => 'http://localhost/example-1.0.0.zip')
    @zip = Registry::Zip.new(@extension)
  end

  it "should unpack the zip" do
    @zip.should_receive(:`).with(/unzip example-1.0.0.zip -d example/).and_return('')
    @zip.unpack
    @zip.path.should =~ /example$/
  end
end