begin
  require 'rails/generators/active_record/migration/migration_generator'
rescue LoadError
end

ActiveRecord::Generators::MigrationGenerator.class_eval do
  remove_argument :name
  remove_argument :attributes
  
  argument :extension_name, :as => :string
  argument :name, :as => :string
  argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
  
  def create_migration_file
    set_local_assigns!
    migration_template "migration.rb", "vendor/extensions/#{extension_name}/db/migrate/#{file_name}.rb"
  end
end


class ExtensionMigrationGenerator < Rails::Generators::Base
  hook_for :orm, :required => true, :as => :migration
end