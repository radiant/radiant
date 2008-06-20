require 'fileutils'
require 'yaml'

module TestingLibrary
  class Environment
    attr_accessor :name, :root, :db_config, :db_schema, :packages
    
    def initialize(name, root, db_config_file, db_schema, &block)
      self.name = name
      self.root = root
      self.db_config = YAML.load(IO.read(db_config_file))
      self.db_schema = db_schema
      self.packages = []
      block.call self
    end
    
    def load(database = nil)
      return if @loaded
      packages.each {|pkg| pkg.load}
      if database
        database_name = db_config[database][:database]
        case database
        when "mysql"
          system "mysqladmin -uroot drop #{database_name} --force"
          system "mysqladmin -uroot create #{database_name}"
        when "sqlite3"
          rm_rf database_name
          touch database_name
        else
          raise "Unknown database #{database}"
        end
        
        ActiveRecord::Base.silence do
          ActiveRecord::Base.configurations = db_config
          ActiveRecord::Base.establish_connection database
          Kernel.load db_schema
        end
      end
      @loaded = true
    end
    
    def databases
      db_config.keys
    end
    
    # name  , scmroot,                            scmpath
    # :rails, "http://svn.rubyonrails.org/rails", "trunk"
    def package(name, *args, &block)
      packages << Package.new(name, root, *args, &block)
    end
  end
  
  class Package
    attr_accessor :name, :root, :scmroot, :scmpath, :scmrev, :libraries
    
    def initialize(*args, &block)
      self.name, self.root, self.scmroot, self.scmpath, self.scmrev = args
      self.scmrev ||= "HEAD"
      self.libraries = []
      block.call self
    end
    
    def add_library(name, options = {})
      library_config = {
        :requires => [],
        :root     => root,
        :scmroot  => scmroot,
        :scmpath  => scmpath,
        :scmrev   => scmrev
      }.merge(options)
      libraries << Library.new(name, library_config)
    end
    
    def after_load(&block)
      @after_load = block
    end
    
    def load
      libraries.each {|lib| lib.load}
      @after_load.call if @after_load
    end
  end
  
  class Library
    attr_accessor :name, :root, :scmroot, :scmpath, :scmrev, :requires
    
    def initialize(name, config)
      self.name     = name
      self.root     = config[:root]
      self.scmroot  = config[:scmroot]
      self.scmpath  = config[:scmpath]
      self.scmrev   = config[:scmrev]
      self.requires = config[:requires]
      @after_update = config[:after_update]
    end
    
    # #{root}/trunk/HEAD/activerecord
    def support_directory
      File.expand_path(File.join(root, scmpath, scmrev, name))
    end
    
    def load
      unless File.directory?(support_directory)
        update
        @after_update.call self if @after_update
      end
      $LOAD_PATH << load_path
      requires.each { |r| require r }
    end
    
    def load_path
      File.join(support_directory, "lib")
    end
    
    def update
      system "svn co -r#{scmrev} #{scmuri} #{support_directory}"
    end
    
    # http://dev.rubyonrails.org/rails/trunk/activerecord
    def scmuri
      File.join(scmroot, scmpath, name)
    end
    
    def ==(other)
      scmroot == other.scmroot
    end
  end
end