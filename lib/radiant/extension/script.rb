require 'active_resource'
require 'tmpdir'
require 'fileutils'
require 'rake'

module Registry
  class Extension < ActiveResource::Base
    self.site = ENV['REGISTRY_URL'] || "http://ext.radiantcms.org/"

    def install
      Registry.const_get(install_type).new(self).install
    end

    def uninstall
      Uninstaller.new(self).uninstall
    end

    def inspect
%{
Name:           #{name}
Description:
  #{description}
Author:         #{author.name} <#{author.email}>
Source code:    #{repository_url}
Download:       #{download_url}
Install type:   #{install_type}
}.strip
    end
  end

  class Action
    def rake(command)
      `rake #{command} RAILS_ENV=#{RAILS_ENV}` if tasks_include? command
    end

    def tasks_include?(command)
      extension = command.split('radiant:extensions:')
      if extension.length > 1
        extension = extension.reject{|e| e.blank? }[0]
      else
        extension = extension.to_s
      end
      rake_file = File.join(RAILS_ROOT, 'vendor', 'extensions', extension) + '/lib/tasks/' + extension + '_extension_tasks.rake'
      if File.exist? rake_file
        load rake_file
      end
      tasks = Rake.application.tasks.map(&:name)
      tasks.include? "#{command}"
    end
    
    def file_utils
      FileUtils
    end
    
    delegate :cd, :cp_r, :rm_r, :to => :file_utils
  end

  class Installer < Action
    attr_accessor :url, :path, :name
    def initialize(url, name)
      self.url, self.name = url, name
    end

    def install
      copy_to_vendor_extensions
      migrate
      update
    end

    def copy_to_vendor_extensions
      cp_r(self.path, File.expand_path(File.join(RAILS_ROOT, 'vendor', 'extensions', name)))
      rm_r(self.path)
    end

    def migrate
      rake "radiant:extensions:#{name}:migrate"
    end

    def update
      rake "radiant:extensions:#{name}:update"
    end
  end

  class Uninstaller < Action
    attr_accessor :name
    def initialize(extension)
      self.name = extension.name
    end

    def uninstall
      migrate_down
      remove_extension_directory
    end

    def migrate_down
      rake "radiant:extensions:#{name}:migrate VERSION=0"
    end

    def remove_extension_directory
      rm_r(File.join(RAILS_ROOT, 'vendor', 'extensions', name))
    end
  end

  class Checkout < Installer
    def initialize(extension)
      super(extension.repository_url, extension.name)
    end

    def checkout_command
      raise "Not Implemented!"
    end

    def install
      checkout
      super
    end

    def checkout
      self.path = File.join(Dir.tmpdir, name)
      cd(Dir.tmpdir) { system "#{checkout_command}" }
    end
  end

  class Download < Installer
    def initialize(extension)
      super(extension.download_url, extension.name)
    end

    def install
      download
      unpack
      super
    end

    def unpack
      raise "Not Implemented!"
    end

    def filename
      File.basename(self.url)
    end

    def download
      require 'open-uri'
      File.open(File.join(Dir.tmpdir, self.filename), 'w') {|f| f.write open(self.url).read }
    end
  end

  class Git < Checkout
    def project_in_git?
      @in_git ||= File.directory?(".git")
    end
    
    def checkout_command
      "git clone #{url} #{name}"
    end
    
    def checkout
      if project_in_git?
        system "git submodule add #{url} vendor/extensions/#{name}"
        cd(File.join('vendor', 'extensions', name)) do
          system "git submodule init && git submodule update"
        end
      else
        super
        cd(path) do
          system "git submodule init && git submodule update"
        end
      end
    end
    
    def copy_to_vendor_extensions
      super unless project_in_git?
    end
  end

  class Subversion < Checkout
    def checkout_command
      "svn checkout #{url} #{name}"
    end
  end

  class Gem < Download
    def download
      # Don't download the gem if it's already installed
      begin
        gem filename.split('-').first
      rescue ::Gem::LoadError
        super
        `gem install #{filename}`
      end
    end

    def unpack
      output = nil
      cd(Dir.tmpdir) do
        output = `gem unpack #{filename.split('-').first}`
      end
      self.path = output.match(/'(.*)'/)[1]
    end
  end

  class Tarball < Download
    def filename
      "#{self.name}.tar"
    end

    def unpack
      output = nil
      cd(Dir.tmpdir) { output = `tar xvf #{filename}` }
      self.path = File.join(Dir.tmpdir, output.split(/\n/).first.split('/').first)
    end
  end

  class Gzip < Tarball
    def filename
      @unpacked ? super : "#{self.name}.tar.gz"
    end

    def unpack
      cd(Dir.tmpdir) { system "gunzip #{self.filename}" }
      @unpacked = true
      super
    end
  end

  class Bzip2 < Tarball
    def filename
      @unpacked ? super : "#{self.name}.tar.bz2"
    end

    def unpack
      cd(Dir.tmpdir) { system "bunzip2 #{self.filename}" }
      @unpacked = true
      super
    end
  end

  class Zip < Download
    def unpack
      output = nil
      cd(Dir.tmpdir) { output = `unzip #{filename} -d #{name}` }
      self.path = File.join(Dir.tmpdir, name)
    end
  end
end

module Radiant
  class Extension
    module Script
      class << self
        def execute(args)
          command = args.shift || 'help'
          begin
            const_get(command.camelize).new(args)
          rescue ArgumentError => e
            puts e.message
            Help.new [command]
          end
        end
      end

      module Util
        attr_accessor :extension_name, :extension

        def to_extension_name(string)
          string.to_s.underscore
        end

        def installed?
          path_match = Regexp.compile("#{extension_name}$")
          extension_paths.any? {|p| p =~ path_match }
        end

        def registered?
          self.extension
        end

        def extension_paths
          [RAILS_ROOT, RADIANT_ROOT].uniq.map { |p| Dir["#{p}/vendor/extensions/*"] }.flatten
        end

        def load_extensions
          Registry::Extension.find(:all)
        end

        def find_extension
          self.extension = load_extensions.find{|e| e.name == self.extension_name }
        end
      end

      class Install
        include Util

        def initialize(args=[])
          raise ArgumentError, "You must specify an extension to install." if args.blank?
          self.extension_name = to_extension_name(args.shift)
          if installed?
            puts "#{extension_name} is already installed."
          else
            find_extension
          end
          if registered?
            extension.install
          else
            raise ArgumentError, "#{extension_name} is not available in the registry."
          end
         end
      end

      class Uninstall
        include Util

        def initialize(args=[])
          raise ArgumentError, "You must specify an extension to uninstall." if args.blank?
          self.extension_name = to_extension_name(args.shift)
          if installed?
            find_extension && extension.uninstall
          else
            puts "#{extension_name} is not installed."
          end
        end
      end

      class Info
        include Util

        def initialize(args=[])
          raise ArgumentError, "You must specify an extension to get info on" if args.blank?
          self.extension_name = to_extension_name(args.shift)
          find_extension and puts extension.inspect
        end
      end

      class Help
        def initialize(args=[])
          command = args.shift
          command = 'help' unless self.class.instance_methods(false).include?(command)
          send(command)
        end

        def help
          $stdout.puts %{Usage:   script/extension command [arguments]

  Available commands:
      #{command_names}

  For help on an individual command:
      script/extension help command
      
  You may install extensions from another registry by setting the REGISTRY_URL
  By default the REGISTRY_URL is set to http://ext.radiantcms.org
  
  Code for the registry application may be found at:
  http://github.com/radiant/radiant-extension-registry/
            }
        end

        def install
          $stdout.puts %{Usage:    script/extension install extension_name

  Installs an extension from information in the global registry.
          }
        end

        def uninstall
          $stdout.puts %{Usage:    script/extension uninstall extension_name

  Removes a previously installed extension from the current project.
            }
        end

        def info
          $stdout.puts %{Usage:    script/extension info extension_name

  Displays registry information about the extension.
          }
        end

        private
          def command_names
            (Radiant::Extension::Script.constants - ['Util']).sort.map {|n| n.underscore }.join(", ")
          end
      end
    end
  end
end
