require 'activesupport'
require 'activerecord'

require 'dataset/version'
require 'dataset/instance_methods'
require 'dataset/base'
require 'dataset/database/base'
require 'dataset/database/mysql'
require 'dataset/database/sqlite3'
require 'dataset/database/postgresql'
require 'dataset/collection'
require 'dataset/load'
require 'dataset/resolver'
require 'dataset/session'
require 'dataset/session_binding'
require 'dataset/record/meta'
require 'dataset/record/fixture'
require 'dataset/record/model'

# == Quick Start
# 
# Write a test. If you want some data in your database, create a dataset.
# Start simple.
# 
#     describe States do
#       dataset do
#         [%w(Colorado CO), %w(North\ Carolina NC), %w(South\ Carolina SC)].each do |name,abbrev|
#           create_record :state, abbrev.downcase, :name => name, :abbrev => abbrev
#         end
#       end
#        
#       it 'should have an abbreviated name'
#         states(:nc).abbrev.should be('NC')
#       end
#        
#       it 'should have a name'
#         states(:nc).name.should be('North Carolin')
#       end
#     end
# 
# Notice that you won't be using _find_id_ or _find_model_ in your tests. You
# use methods like _states_ and _state_id_, as in the example above.
#
# When you find that you're seeing patterns in the data you are creating, pull it into a class.
#
#     spec/datasets/states.rb
#     class StatesDataset < Dataset::Base
#       def load
#         # create useful data
#       end
#     end
#
#     spec/models/state.rb
#     describe State do
#       dataset :states
#     end
#
# == Installation
#
# Dataset is installed into your testing environment by requiring the library,
# then including it into the class that will be the context of your test
# methods.
#
#    require 'dataset'
#    class Test::Unit::TestCase
#      include Dataset
#      datasets_directory "#{RAILS_ROOT}/test/datasets"
#    end
#
# Note that should you desire your Dataset::Base subclasses be
# auto-discovered, you can set the _datasets_directory_.
#
module Dataset
  def self.included(test_context) # :nodoc:
    if test_context.name =~ /World\Z/
      require 'dataset/extensions/cucumber'
    elsif test_context.name =~ /TestCase\Z/
      require 'dataset/extensions/test_unit'
    elsif test_context.name =~ /ExampleGroup\Z/
      require 'dataset/extensions/rspec'
    else
      raise "I don't understand your test framework"
    end
    
    test_context.extend ContextClassMethods
  end
  
  # Methods that are added to the class that Dataset is included in (the test
  # context class).
  #
  module ContextClassMethods
    def self.extended(context_class) # :nodoc:
      context_class.module_eval do
        include InstanceMethods
        superclass_delegating_accessor :dataset_session
      end
    end
    
    mattr_accessor :datasets_database_dump_path
    self.datasets_database_dump_path = File.expand_path(RAILS_ROOT + '/tmp/dataset') if defined?(RAILS_ROOT)
    
    # Replaces the default Dataset::Resolver with one that will look for
    # dataset class definitions in the specified directory. Captures of the
    # database will be stored in a subdirectory 'tmp' (see
    # Dataset::Database::Base).
    def datasets_directory(path)
      Dataset::Resolver.default = Dataset::DirectoryResolver.new(path)
      Dataset::ContextClassMethods.datasets_database_dump_path = File.join(path, '/tmp/dataset')
    end
    
    def add_dataset(*datasets, &block) # :nodoc:
      dataset_session = dataset_session_in_hierarchy
      datasets.each { |dataset| dataset_session.add_dataset(self, dataset) }
      dataset_session.add_dataset(self, Class.new(Dataset::Block) {
        define_method :doload, block
      }) unless block.nil?
    end
    
    def dataset_session_in_hierarchy # :nodoc:
      self.dataset_session ||= begin
        database_spec = ActiveRecord::Base.configurations['test'].with_indifferent_access
        database_class = Dataset::Database.const_get(database_spec[:adapter].classify)
        database = database_class.new(database_spec, Dataset::ContextClassMethods.datasets_database_dump_path)
        Dataset::Session.new(database)
      end
    end
  end
end