ENV["RAILS_ENV"] = 'test'
RAILS_ENV = 'test'
BASE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../'))
require 'fileutils'
require 'tempfile'
require 'spec'
require File.join(BASE_ROOT, 'spec/matchers/generator_matchers')
require File.join(BASE_ROOT, 'lib/plugins/string_extensions/lib/string_extensions')

unless defined?(::GENERATOR_SUPPORT_LOADED) && ::GENERATOR_SUPPORT_LOADED
  # this is so we can require ActiveSupport
  $:.unshift File.join(BASE_ROOT, 'vendor/rails/activesupport/lib')
  # This is so the initializer and Rails::Generator is properly found
  $:.unshift File.join(BASE_ROOT, 'vendor/rails/railties/lib')
  require 'active_support'

  # Mock out what we need from AR::Base
  module ActiveRecord
    class Base
      class << self
        attr_accessor :pluralize_table_names, :timestamped_migrations
      end
      self.pluralize_table_names = true
      self.timestamped_migrations = true
    end

    module ConnectionAdapters
      class Column
        attr_reader :name, :default, :type, :limit, :null, :sql_type, :precision, :scale

        def initialize(name, default, sql_type = nil)
          @name = name
          @default = default
          @type = @sql_type = sql_type
        end

        def human_name
          @name.humanize
        end
      end
    end
  end

  # Mock up necessities from ActionView
  module ActionView
    module Helpers
      module ActionRecordHelper; end
      class InstanceTag; end
    end
  end

  # Set RAILS_ROOT appropriately fixture generation
  tmp_dir = File.expand_path(File.join(Dir.tmpdir, 'radiant'))
  $stdout << "#{tmp_dir}\n\n"
  FileUtils.mkdir_p tmp_dir

  if defined? RADIANT_ROOT
    RADIANT_ROOT.replace tmp_dir
  else
    RADIANT_ROOT = tmp_dir
  end

  if defined? RAILS_ROOT
    RAILS_ROOT.replace tmp_dir
  else
    RAILS_ROOT = tmp_dir
  end

  require 'initializer'

  # Mocks out the configuration
  module Rails
    def self.configuration
      Rails::Configuration.new
    end
  end

  require 'rails_generator'

  module GeneratorSpecHelperMethods
    # Instantiates the Generator.
    def build_generator(name, params)
      Rails::Generator::Base.instance(name, params)
    end

    # Runs the +create+ command (like the command line does).
    def run_generator(name, params)
      silence_generator do
        build_generator(name, params).command(:create).invoke!
      end
    end

    # Silences the logger temporarily and returns the output as a String.
    def silence_generator
      logger_original = Rails::Generator::Base.logger
      myout = StringIO.new
      Rails::Generator::Base.logger = Rails::Generator::SimpleLogger.new(myout)
      yield if block_given?
      Rails::Generator::Base.logger = logger_original
      myout.string
    end
  end

  share_as :AllGenerators do
    include FileUtils
    include GeneratorSpecHelperMethods
  
    before(:all) do
      ActiveRecord::Base.pluralize_table_names = true
    
      mkdir_p "#{RADIANT_ROOT}/app"
      mkdir_p "#{RADIANT_ROOT}/config"
      mkdir_p "#{RADIANT_ROOT}/db"
      mkdir_p "#{RADIANT_ROOT}/vendor/generators"
      mkdir_p "#{RADIANT_ROOT}/vendor/extensions"

      File.open("#{RADIANT_ROOT}/config/routes.rb", 'w') do |f|
        f << "ActionController::Routing::Routes.draw do |map|\n\nend"
      end
    end
  
    after(:all) do
      %w(app db config vendor).each do |dir|
        rm_rf File.join(RADIANT_ROOT, dir)
      end
    end
  end
  
  share_as :AllExtensionGenerators do
    before(:all) do
      cp_r File.join(BASE_ROOT, 'spec/fixtures/example_extension'), File.join(RADIANT_ROOT, 'vendor/extensions/example')
    end
  end

  GENERATOR_SUPPORT_LOADED = true
end

Spec::Runner.configure do |config|
  config.include(Spec::Matchers::GeneratorMatchers)
end

