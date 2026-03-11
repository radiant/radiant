module Radiant
  module Generators
    class ExtensionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_engine_directory
        empty_directory extension_path
        empty_directory "#{extension_path}/app/controllers"
        empty_directory "#{extension_path}/app/models"
        empty_directory "#{extension_path}/app/views"
        empty_directory "#{extension_path}/config"
        empty_directory "#{extension_path}/db/migrate"
        empty_directory "#{extension_path}/lib/radiant"
        empty_directory "#{extension_path}/test"
      end

      def create_entry_point
        # Bundler auto-requires "radiant/file_name" for gem "radiant-file_name"
        template "entry_point.rb.tt", "#{extension_path}/lib/radiant/#{file_name}.rb"
      end

      def create_engine_file
        template "engine.rb.tt", "#{extension_path}/lib/radiant/#{file_name}/engine.rb"
        empty_directory "#{extension_path}/lib/radiant/#{file_name}"
      end

      def create_gemspec
        template "gemspec.rb.tt", "#{extension_path}/radiant-#{file_name}.gemspec"
      end

      def create_gemfile
        template "Gemfile.tt", "#{extension_path}/Gemfile"
      end

      def create_readme
        template "README.md.tt", "#{extension_path}/README.md"
      end

      def create_routes
        template "routes.rb.tt", "#{extension_path}/config/routes.rb"
      end

      def create_test_helper
        template "test_helper.rb.tt", "#{extension_path}/test/test_helper.rb"
      end

      private

      def extension_path
        "radiant-#{file_name}"
      end

      def class_name
        file_name.camelize
      end

      def module_name
        class_name
      end
    end
  end
end
