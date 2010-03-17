module Dataset
  
  # The superclass of your Dataset classes.
  #
  # It is recommended that you create a dataset using the Dataset::Block
  # method first, then grow into using classes as you recognize patterns in
  # your test data creation. This will help you to keep simple things simple.
  #
  class Base
    class << self
      # Allows a subclass to define helper methods that should be made
      # available to instances of this dataset, to datasets that use this
      # dataset, and to tests that use this dataset.
      #
      # This feature is great for providing any kind of method that would help
      # test the code around the data your dataset creates. Be careful,
      # though, to keep from adding business logic to these methods! That
      # belongs in your production code.
      #
      def helpers(&method_definitions)
        @helper_methods ||= begin
          mod = Module.new
          include mod
          mod
        end
        @helper_methods.module_eval &method_definitions
      end
      
      def helper_methods # :nodoc:
        @helper_methods
      end
      
      # Allows a subsclass to declare which datasets it uses.
      #
      # Dataset is designed to promote 'design by composition', rather than
      # 'design by inheritance'. You should not use class hiearchies to share
      # data and code in your datasets. Instead, you can write something like
      # this:
      #
      #   class PeopleDataset < Dataset::Base; end
      #   class DepartmentsDataset < Dataset::Base; end
      #   class OrganizationsDataset < Dataset::Base
      #     uses :people, :departments
      #   end
      #
      # When the OrganizationsDataset is loaded, it will have all the data
      # from the datasets is uses, as well as all of the helper methods
      # defined by those datasets.
      #
      # When a dataset uses other datasets, and those datasets themselves use
      # datasets, things will be loaded in the order of dependency you would
      # expect:
      #
      #   C uses B
      #   A uses C
      #   B, C, A is the load order
      # 
      def uses(*datasets)
        @used_datasets = datasets
      end
      
      def used_datasets # :nodoc:
        @used_datasets
      end
    end
    
    # Invoked once before a collection of tests is run. If you use a dataset
    # in multiple test classes, it will be called once for each of them -
    # remember that the database will be cleared at the beginning of running a
    # 'suite' or 'group' of tests, unless you are using nested contexts (as in
    # nested describe blocks in RSpec).
    #
    # Override this method in your subclasses.
    #
    def load; end
  end
  
  # The easiest way to create some data before a suite of tests is run is by
  # using a Dataset::Block. An example works wonders:
  #
  #    class PeopleTest < Test::Unit::TestCase
  #      dataset do
  #        create_record :person, :billy, :name => 'Billy'
  #      end
  #            
  #      def test_name
  #        assert_equal 'Billy', people(:billy).name
  #      end
  #    end
  #
  # The database will be cleared and billy will be inserted once before
  # running each of the tests within a transaction. All the normal transaction
  # fixtures stuff will still work.
  #
  # One of the great features of Dataset, at least when things get really
  # interesting in your data needs, is that nested contexts will be additive.
  # Consider this:
  #
  #    describe Something do
  #      dataset :a              => Dataset :a is loaded (at the right time)
  #         
  #      it 'should whatever'
  #      end
  #         
  #      describe More do
  #        dataset :b            => Dataset :b is loaded. :a data is still there
  #           
  #        it 'should'
  #        end
  #      end
  #         
  #      describe Another do     => Database is restored to :a, without re-running :a logic
  #        it 'should'
  #        end
  #      end
  #    end
  #
  # == Instance Variables
  #
  # You may also assign instance variables in a dataset block, and they will
  # be available to your test methods. You have to be careful with this in a
  # similar way that you must with an RSpec before :all block. Since the
  # instance variables are pointing to the same instances accross all tests,
  # things can get weird if you intend to change their state. It's best use is
  # for loading objects that you want to read a lot without loading over and
  # over again for each test.
  #
  # == Building on Other Datasets
  #
  # You may pass any number of Dataset::Base subclasses - or better yet, their
  # names - to the dataset method. When you use a block, this adds a lot of
  # clarity:
  #
  #    class PersonTest < Test::Unit::TestCase
  #      dataset :organization, :people do
  #        id = create_record :person, :second_admin, :name => 'Admin Three'
  #        create_record :organization_administratorship, :organization_id => organization_id(:first_bank), :person_id => id
  #      end
  #       
  #      def test_admins
  #        assert organizations(:first_bank).admins.include?(people(:second_admin))
  #      end
  #    end
  #
  # == Reusing a Dataset
  #
  # When you need to go beyond the block, create a Dataset::Base subclass!
  class Block < Base
    include Dataset::InstanceMethods
    
    def load # :nodoc:
      dataset_session_binding.install_block_variables(self)
      doload
      dataset_session_binding.copy_block_variables(self)
    end
  end
end