module Spec
  module Matchers
    module GeneratorMatchers
      class DirectoryGenerated
        def initialize(dir)
          @dir = dir
        end
        
        def matches?(base)
          @base = base
          @path = File.join(RADIANT_ROOT, @base, @dir)
          File.exist?(@path) && File.directory?(@path)
        end
        
        def failure_message
          "expected directory '#{@path}' should exist but doesn't"
        end
        
        def negative_failure_message
           "expected no directory, but directory '#{@path}' was found"
        end
      end
      
      def have_generated_directory(dir)
        FileGenerated.new(dir)
      end
      
      class FileGenerated
        def initialize(file)
          @file = file
        end
        
        def matches?(base)
          @base = base
          @path = File.join(RADIANT_ROOT, @base, @file)
          if file_exists(@path) && block_given?
            File.open(@path) { |f| yield(f.read) }
          end
          file_exists(@path)
        end
        
        def failure_message
          "expected file '#{@path}' should exist but doesn't"
        end
        
        def negative_failure_message
           "expected no file, but file '#{@path}' was found"
        end
        
        def file_exists(path)
          File.exist?(path)
        end
      end
      
      def have_generated_file(file)
        FileGenerated.new(file)
      end
      
      def have_generated_class(path, parent = nil)
        simple_matcher "directory contains generated class file" do |dir, matcher|
          matcher.failure_message = "the file '#{path}.rb' should be a class"
          
          if path.split('/').size > 3
            path =~ /\/?(\d+_)?(\w+)\/(\w+)$/
            class_name = "#{$2.camelize}::#{$3.camelize}"
          else
            path =~ /\/?(\d+_)?(\w+)$/
            class_name = $2.camelize
          end
          
          dir.should have_generated_file("#{path}.rb") do |body|
            body.should match(/class #{class_name}#{parent.nil? ? '':" < #{parent}"}\n((\n|\s*.*\n)*)end/)
            yield $1 if block_given?
          end
        end
      end
      
      def have_generated_module(path, parent = nil)
        simple_matcher "directory contains generated class file" do |dir, matcher|
          matcher.failure_message = "the file '#{path}.rb' should be a module"
          
          if path.split('/').size > 3
            path =~ /\/?(\d+_)?(\w+)\/(\w+)$/
            module_name = "#{$2.camelize}::#{$3.camelize}"
          else
            path =~ /\/?(\d+_)?(\w+)$/
            module_name = $2.camelize
          end
          
          dir.should have_generated_file("#{path}.rb") do |body|
            body.should match(/module #{module_name}#{parent.nil? ? '':" < #{parent}"}\n((\n|\s*.*\n)*)end/)
            yield $1 if block_given?
          end
        end
      end
      
      def have_generated_spec(path, class_name = true)
        simple_matcher "directory contains generated model spec" do |dir, matcher|
          matcher.failure_message = "the file '#{path}.rb' should be a spec"
          
          if path.split('/').size > 3
            path =~ /\/?(\d+_)?(\w+)\/(\w+)$/
            class_name = "#{$2.camelize}::#{$3.camelize}"
          else
            path =~ /\/?(\d+_)?(\w+)$/
            class_name = $2.camelize
          end
          
          dir.should have_generated_file("#{path}_spec.rb") do |body|
            if class_name
              body.should match(/describe #{class_name} do\n((\s*.*\n)+)\s*end/)
              yield $1 if block_given?
            else
              yield body if block_given?
            end
          end
        end
      end
      
      def have_generated_controller_for(name, parent = "ApplicationController")
        have_generated_class "app/controllers/#{name.to_s.underscore}_controller", parent do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_model_for(name, parent = "ActiveRecord::Base")
        have_generated_class "app/models/#{name.to_s.underscore}", parent do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_model_spec_for(name)
        have_generated_spec "spec/models/#{name.to_s.underscore}" do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_controller_spec_for(name)
        have_generated_spec "spec/controllers/#{name.to_s.underscore}_controller" do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_helper_spec_for(name)
        have_generated_spec "spec/helpers/#{name.to_s.underscore}_helper" do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_view_specs_for(name, *actions)
        simple_matcher "directory should contain generated view specs" do |dir, matcher|
          actions.each do |action|
            dir.should have_generated_spec("spec/views/#{name.to_s.underscore}/#{action.to_s.underscore}_view", false) do |body|
              yield body if block_given?
            end
          end
        end
      end
      
      def have_generated_helper_for(name)
        have_generated_module "app/helpers/#{name.to_s.underscore}_helper" do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_functional_test_for(name, parent = "ActionController::TestCase")
        have_generated_class "test/functional/#{name.to_s.underscore}_controller_test", parent do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_unit_test_for(name, parent = "ActiveSupport::TestCase")
        have_generated_class "test/unit/#{name.to_s.underscore}_test", parent do |body|
          yield body if block_given?
        end
      end
      
      def have_generated_migration(name, parent = "ActiveRecord::Migration")
        simple_matcher 'directory should contain migration file' do |dir, matcher|
          root_path = File.expand_path(File.join(RADIANT_ROOT, dir))
          file = Dir.glob("#{root_path}/db/migrate/*_#{name.to_s.underscore}.rb").first
          file = file.match(/db\/migrate\/[0-9]+_\w+/).to_s
          dir.should have_generated_class(file, parent) do |body|
            yield body if block_given?
          end
        end
      end
      
      def have_generated_yaml(path)
        simple_matcher "directory contains generated YAML file" do |dir, matcher|
          dir.should have_generated_file("#{path}.yml") do |body|
            yaml = YAML.load(body.to_s)
            yaml.should be
            yield yaml if block_given?
          end
        end
      end
      
      def have_generated_fixtures_for(name)
        have_generated_yaml "test/fixtures/#{name.to_s.underscore}" do |yaml|
          yield yaml if block_given?
        end
      end
      
      def have_generated_views_for(name, actions, suffix = "html.erb")
        simple_matcher "directory should contain generated views" do |dir, matcher|
          actions.each do |action|
            have_generated_file("app/views/#{name.to_s.underscore}/#{action}.#{suffix}") do |body|
              yield body if block_given?
            end
          end
        end
      end
      
      def have_methods(*methods)
        simple_matcher "file body contains generated method definition" do |body, matcher|
          methods.each do |name|
            body.should match(/^  def #{name}(\(.+\))?\n((\n|   .*\n)*)  end/)
            yield(name, $2) if block_given?
          end
        end
      end
      
      def have_generated_column(name, type)
        simple_matcher "migration defines column" do |body, matcher|
          body.should match(/t\.#{type.to_s} :#{name.to_s}/)
        end
      end
      
    end
  end
end
