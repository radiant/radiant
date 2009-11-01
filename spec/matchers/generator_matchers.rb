module Spec
  module Matchers
    module GeneratorMatchers
      class DirectoryGenerated
        def initialize(dir)             @dir = dir end
        def failure_message()           "expected directory '#{@path}' should exist but doesn't" end
        def negative_failure_message()  "expected no directory, but directory '#{@path}' was found" end
      
        def matches?(base)
          @base = base
          @path = File.join(RADIANT_ROOT, @base, @dir)
          File.exist?(@path) && File.directory?(@path)
        end
      end
    
      class FileGenerated
        def initialize(file)            @file = file end
        def failure_message()           "expected file '#{@path}' should exist but doesn't" end
        def negative_failure_message()  "expected no file, but file '#{@path}' was found" end
      
        def matches?(base)
          @base = base
          @path = File.join(RADIANT_ROOT, @base, @file)
          if (exists = File.exist?(@path)) && block_given?  
            File.open(@path) { |f| yield(f.read) }
          end
          return exists
        end
      end
      
      class YamlGenerated
        def initialize(path)            @path = path end
        def failure_message()           "the file '#{@path}.yml' should be a YAML file" end
        def negative_failure_message()  "expected no file, but file '#{@path}.yml' was found" end
        
        def matches?(base)
          FileGenerated.new("#{@path}.yaml").matches?(base) do |body|
            yield(YAML.load(body.to_s)) if block_given?
            return true
          end
          false
        end
      end
      
      class ClassGenerated
        def initialize(path, parent=nil)  @path = path; @parent = parent; end
        def failure_message()             "the file '#{@path}.rb' should be a class" end
        def negative_failure_message()    "expected no file, but file '#{@path}.rb' was found" end
        
        def matches?(base)
          if @path.split('/').size > 3
            @path =~ /\/?(\d+_)?(\w+)\/(\w+)$/
            class_name = "#{$2.camelize}::#{$3.camelize}"
          else
            @path =~ /\/?(\d+_)?(\w+)$/
            class_name = $2.camelize
          end
          
          FileGenerated.new("#{@path}.rb").matches?(base) do |body|
            match_data = body.match(/class #{class_name}#{@parent.nil? ? '':" < #{@parent}"}\n((\n|\s*.*\n)*)end/)
            yield(match_data[1]) if block_given? && !!match_data
            return !!match_data
          end
          false
        end
      end
      
      class ModuleGenerated
        def initialize(path, parent=nil)  @path = path; @parent = parent; end
        def failure_message()             "the file '#{@path}.rb' should be a module" end
        def negative_failure_message()    "expected no file, but file '#{@path}.rb' was found" end
        
        def matches?(base)
          if @path.split('/').size > 3
            @path =~ /\/?(\d+_)?(\w+)\/(\w+)$/
            module_name = "#{$2.camelize}::#{$3.camelize}"
          else
            @path =~ /\/?(\d+_)?(\w+)$/
            module_name = $2.camelize
          end
          
          FileGenerated.new("#{@path}.rb").matches?(base) do |body|
            match_data = body.match(/module #{module_name}#{@parent.nil? ? '':" < #{@parent}"}\n((\n|\s*.*\n)*)end/)
            yield(match_data[1]) if block_given? && !!match_data
            return !!match_data
          end
          false
        end
      end
      
      class SpecGenerated
        def initialize(path, class_name=true) @path = path; @class_name = class_name; end
        def failure_message()                 "the file '#{@path}.rb' should be a spec" end
        def negative_failure_message()        "expected no file, but file '#{@path}.rb' was found" end
        
        def matches?(base)
          unless @class_name == false
            if @path.split('/').size > 3
              @path =~ /\/?(\d+_)?(\w+)\/(\w+)$/
              @class_name = "#{$2.camelize}::#{$3.camelize}"
            else
              @path =~ /\/?(\d+_)?(\w+)$/
              @class_name = $2.camelize
            end
          end
          
          FileGenerated.new("#{@path}_spec.rb").matches?(base) do |body|
            if @class_name
              match_data = body.match(/describe #{@class_name} do\n((\s*.*\n)+)\s*end/)
              yield(match_data[1]) if block_given? && !!match_data
              return !!match_data
            else
              yield(body) if block_given?
              return true
            end
          end
          false
        end
      end
      
      class MigrationGenerated
        def initialize(name, parent="ActiveRecord::Migration")  @name = name; @parent = parent; end
        def failure_message()                                   "the file '#{@path}' should be a spec" end
        def negative_failure_message()                          "expected no file, but file '#{@path}.rb' was found" end
        
        def matches?(base)
          root_path = File.expand_path(File.join(RADIANT_ROOT, base))
          @path = Dir.glob("#{root_path}/db/migrate/*_#{@name.to_s.underscore}.rb").first
          return false if @path.nil?
          @path = @path.match(/db\/migrate\/[0-9]+_\w+/).to_s
          
          ClassGenerated.new(@path, @parent).matches?(base) do |body|
            yield(body) if block_given?
            return true
          end
          false
        end
      end
      
      class MethodMatcher
        def initialize(name)            @name = name end
        def failure_message()           "the string should contain a method definition for #{@name}" end
        def negative_failure_message()  "expected no method definition for #{@name}, but found it" end
        
        def matches?(actual)
          match_data = actual.match(/^\s*def #{@name}(\(.+\))?\n((\n|\s+.*\n)*)\s*end/)
          if !!match_data && block_given?
            yield(match_data[2])
          end
          return !!match_data
        end
      end      
      
      def have_generated_directory(dir)
        DirectoryGenerated.new(dir)
      end
      
      def have_generated_file(file)
        FileGenerated.new(file)
      end
      
      def have_generated_class(path, parent = nil)
        ClassGenerated.new(path, parent)
      end
      
      def have_generated_module(path, parent = nil)
        ModuleGenerated.new(path, parent)
      end
      
      def have_generated_spec(path, class_name = true)
        SpecGenerated.new(path, class_name)
      end
      
      def have_generated_controller_for(name, parent = "ApplicationController")
        ClassGenerated.new("app/controllers/#{name.to_s.underscore}_controller", parent)
      end
      
      def have_generated_model_for(name, parent = "ActiveRecord::Base")
        ClassGenerated.new("app/models/#{name.to_s.underscore}", parent)
      end
      
      def have_generated_model_spec_for(name)
        SpecGenerated.new("spec/models/#{name.to_s.underscore}")
      end
      
      def have_generated_controller_spec_for(name)
        SpecGenerated.new("spec/controllers/#{name.to_s.underscore}_controller")
      end
      
      def have_generated_helper_spec_for(name)
        SpecGenerated.new("spec/helpers/#{name.to_s.underscore}_helper")
      end
      
      def have_generated_view_spec_for(controller, action)
        SpecGenerated.new("spec/views/#{controller.to_s.underscore}/#{action.to_s.underscore}_view", false)
      end
      
      def have_generated_helper_for(name)
        ModuleGenerated.new("app/helpers/#{name.to_s.underscore}_helper")
      end
      
      def have_generated_functional_test_for(name, parent = "ActionController::TestCase")
        ClassGenerated.new("test/functional/#{name.to_s.underscore}_controller_test", parent)
      end
      
      def have_generated_unit_test_for(name, parent = "ActiveSupport::TestCase")
        ClassGenerated.new("test/unit/#{name.to_s.underscore}_test", parent)
      end
      
      def have_generated_migration(name, parent = "ActiveRecord::Migration")
        MigrationGenerated.new(name, parent)
      end
      
      def have_generated_yaml(path)
        YamlGenerated.new(path)
      end
      
      def have_generated_fixtures_for(name)
        YamlGenerated.new("test/fixtures/#{name.to_s.underscore}")
      end
      
      def have_generated_view_for(name, action, suffix = "html.erb")
        FileGenerated.new("app/views/#{name.to_s.underscore}/#{action}.#{suffix}")
      end
      
      def have_method(name)
        MethodMatcher.new(name)
      end
      
      def have_generated_column(name, type)
        simple_matcher("migration defines column") { |given| given =~ /t\.#{type.to_s} :#{name.to_s}/ }
      end
    end
  end
end
