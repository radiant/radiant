module Dataset
  # An error that will be raised when an attempt is made to load a named model
  # that doesn't exist. For example, if you do people(:jenny), and yet no
  # record was ever created with the symbolic name :jenny, this error will be
  # raised.
  #
  class RecordNotFound < StandardError
    def initialize(record_type, symbolic_name)
      super "There is no '#{record_type.name}' found for the symbolic name ':#{symbolic_name}'."
    end
  end
  
  # Whenever you use Dataset::RecordMethods, you will get finder methods in
  # your tests that help you load instances of the records you have created
  # (or named models).
  #
  #    create_record :person, :jimmy, :name => 'Jimmy'
  #    person_id(:jimmy)  => The id was captured from create_record
  #    people(:jimmy)     => The same as Jimmy.find(person_id(:jimmy))
  #
  # The methods will not exist in a test unless it utilizes a dataset (or
  # defines one itself through the block technique) that creates a record for
  # the type.
  #
  # You may also pass multiple names to these methods, which will have them
  # return an array of values.
  #
  #    people(:jimmy, :jane, :jeff)     => [<# Person :name => 'Jimmy'>, <# Person :name => 'Jane'>, <# Person :name => 'Jeff'>]
  #    person_id(:jimmy, :jane, :jeff)  => [1, 2, 3]
  #
  # NOTE the plurality of the instance finder, versus the singularity of the
  # id finder.
  #
  # == Single Table Inheritence
  #
  #    class Person < ActiveRecord::Base; end
  #    class User < Person; end
  #
  #    create_record :user, :bobby, :name => 'Bobby'
  #
  #    people(:bobby) OR users(:bobby)
  #
  module ModelFinders
    def create_finder(record_meta) # :nodoc:
      @finders_generated ||= []
      
      return if @finders_generated.include?(record_meta)
      
      record_meta.model_finder_names.each do |finder_name|
        unless instance_methods.include?(finder_name)
          define_method finder_name do |*symbolic_names|
            names = Array(symbolic_names)
            models = names.inject([]) do |c,n|
              c << dataset_session_binding.find_model(record_meta, n); c
            end
            names.size == 1 ? models.first : models
          end
        end
      end
      
      record_meta.id_finder_names.each do |finder_name|
        unless instance_methods.include?(finder_name)
          define_method finder_name do |*symbolic_names|
            names = Array(symbolic_names)
            ids = names.inject([]) do |c,n|
              c << dataset_session_binding.find_id(record_meta, n); c
            end
            names.size == 1 ? ids.first : ids
          end
        end
      end
      
      @finders_generated << record_meta
    end
  end
  
  # Any Dataset::Base subclass, dataset block, or test method in a
  # dataset-using test context (including setup/teardown/before/after) may
  # create and access models through these methods. Note that you should use
  # Dataset::ModelFinders if you can for finding your created data.
  #
  module RecordMethods
    
    # Similar to old fashioned fixtures, this will do a direct database
    # insert, without running any validations or preventing you from writing
    # attr_protected attributes. Very nice for speed, but kind of a pain if
    # you have complex structures or hard to keep right validations.
    #
    #     create_record :type, :symbolic_name, :attr1 => 'value', :attr2 => 'value', :etc => 'etc'
    #
    # The _symbolic_name_ is an optional parameter. You may replace _type_
    # with an ActiveRecord::Base subclass or anything that works with:
    #
    #    to_s.classify.constantize
    #
    # The id of the model will be a hash of the symbolic name.
    #
    def create_record(*args)
      dataset_session_binding.create_record(*args)
    end
    
    # This will instantiate your model class and assign each attribute WITHOUT
    # using mass assignment. Validations will be run. Very nice for complex
    # structures or hard to keep right validations, but potentially a bit
    # slower, since it runs through all that ActiveRecord code.
    #
    #     create_model :type, :symbolic_name, :attr1 => 'value', :attr2 => 'value', :etc => 'etc'
    #
    # The _symbolic_name_ is an optional parameter. You may replace _type_
    # with an ActiveRecord::Base subclass or anything that works with:
    #
    #    to_s.classify.constantize
    #
    # The id of the record will be kept from the instance that is saved.
    #
    def create_model(*args)
      dataset_session_binding.create_model(*args)
    end
    
    # Dataset will track each of the records it creates by symbolic name to
    # id. When you need the id of a record, there is no need to go to the
    # database.
    #
    #    find_id :person, :bobby    => 23425234
    #
    # You may pass one name or many, with many returning an Array of ids.
    #
    def find_id(*args)
      dataset_session_binding.find_id(*args)
    end
    
    # Dataset will track each of the records it creates by symbolic name to
    # id. When you need an instance of a record, the stored id will be used to
    # do the fastest lookup possible: Person.find(23425234).
    #
    #    find_model :person, :bobby    => <#Person :id => 23425234, :name => 'Bobby'>
    #
    # You may pass one name or many, with many returning an Array of
    # instances.
    #
    def find_model(*args)
      dataset_session_binding.find_model(*args)
    end
    
    # This is a great help when you want to create records in a custom helper
    # method, then make it and maybe things associated to it available to
    # tests through the Dataset::ModelFinders.
    #
    #    thingy = create_very_complex_thingy_and_stuff
    #    name_model thingy, :thingy_bob
    #    name_model thingy.part, :thingy_part
    #
    # In tests:
    #
    #    thingies(:thingy_bob)
    #    parts(:thingy_part)
    #
    def name_model(*args)
      dataset_session_binding.name_model(*args)
    end
    
    # Converts string names into symbols for use in naming models
    # 
    #     name_to_sym 'my name' => :my_name
    #     name_to_sym 'RPaul'  => :r_paul
    # 
    def name_to_sym(name)
      dataset_session_binding.name_to_sym(name)
    end
  end
  
  class SessionBinding # :nodoc:
    attr_reader :database, :parent_binding
    attr_reader :model_finders, :record_methods
    attr_reader :block_variables
    
    def initialize(database_or_parent_binding)
      @id_cache = Hash.new {|h,k| h[k] = {}}
      @record_methods = new_record_methods_module
      @model_finders = new_model_finders_module
      @block_variables = Hash.new
      
      case database_or_parent_binding
      when Dataset::SessionBinding
        @parent_binding = database_or_parent_binding
        @database = parent_binding.database
        @model_finders.module_eval { include database_or_parent_binding.model_finders }
        @block_variables.update(database_or_parent_binding.block_variables)
      else 
        @database = database_or_parent_binding
      end
    end
    
    def copy_block_variables(dataset_block)
      dataset_block.instance_variables.each do |name|
        self.block_variables[name] = dataset_block.instance_variable_get(name)
      end
    end
    
    def create_model(record_type, *args)
      insert(Dataset::Record::Model, record_type, *args)
    end
    
    def create_record(record_type, *args)
      insert(Dataset::Record::Fixture, record_type, *args)
    end
    
    def find_id(record_type_or_meta, symbolic_name)
      record_meta = record_meta_for_type(record_type_or_meta)
      if local_id = @id_cache[record_meta.id_cache_key][symbolic_name]
        local_id
      elsif !parent_binding.nil?
        parent_binding.find_id record_meta, symbolic_name
      else
        raise RecordNotFound.new(record_meta, symbolic_name)
      end
    end
    
    def find_model(record_type_or_meta, symbolic_name)
      record_meta = record_meta_for_type(record_type_or_meta)
      if local_id = @id_cache[record_meta.id_cache_key][symbolic_name]
        record_meta.record_class.find local_id
      elsif !parent_binding.nil?
        parent_binding.find_model record_meta, symbolic_name
      else
        raise RecordNotFound.new(record_meta, symbolic_name)
      end
    end
    
    def install_block_variables(target)
      block_variables.each do |k,v|
        target.instance_variable_set(k,v)
      end
    end
    
    def name_model(record, symbolic_name)
      record_meta = database.record_meta(record.class)
      @model_finders.create_finder(record_meta)
      @id_cache[record_meta.id_cache_key][symbolic_name] = record.id
      record
    end
    
    def record_meta_for_type(record_type)
      record_type.is_a?(Record::Meta) ? record_type : begin
        record_class = resolve_record_class(record_type)
        database.record_meta(record_class)
      end
    end
    
    def name_to_sym(name)
      name.to_s.underscore.gsub("'", "").gsub("\"", "").gsub(" ", "_").to_sym if name
    end
    
    protected
      def insert(dataset_record_class, record_type, *args)
        symbolic_name, attributes = extract_creation_arguments args
        record_meta  = record_meta_for_type(record_type)
        record       = dataset_record_class.new(record_meta, attributes, symbolic_name, self)
        return_value = nil
        
        @model_finders.create_finder(record_meta)
        ActiveRecord::Base.silence do
          return_value = record.create
          @id_cache[record_meta.id_cache_key][symbolic_name] = record.id
        end
        return_value
      end
      
      def extract_creation_arguments(arguments)
        if arguments.size == 2 && arguments.last.kind_of?(Hash)
          arguments
        elsif arguments.size == 1 && arguments.last.kind_of?(Hash)
          [nil, arguments.last]
        elsif arguments.size == 1 && arguments.last.kind_of?(Symbol)
          [arguments.last, Hash.new]
        else
          [nil, Hash.new]
        end
      end
      
      def new_model_finders_module
        mod = Module.new
        dataset_binding = self
        mod.module_eval do
          define_method :dataset_session_binding do
            dataset_binding
          end
        end
        mod.extend ModelFinders
        mod
      end
      
      def new_record_methods_module
        mod = Module.new do
          include RecordMethods
        end
        dataset_binding = self
        mod.module_eval do
          define_method :dataset_session_binding do
            dataset_binding
          end
        end
        mod
      end
      
      def resolve_record_class(record_type)
        case record_type
        when Symbol
          resolve_record_class record_type.to_s.singularize.camelize
        when Class
          record_type
        when String
          record_type.constantize
        end
      end
  end
end