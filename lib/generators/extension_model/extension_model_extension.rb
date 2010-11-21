class ExtensionModelGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  remove_argument :name
  argument :extension_name, :type => :string
  argument :name, :type => :string, :default => :welcome
  argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
  class_option :with_test_unit, :type => :boolean, :default => false

  def directories
    empty_directory File.join(class_path, 'app/models')
    
    unless test_unit?
      empty_directory File.join(class_path, 'spec/models')
    end
  end
  
  def files
    template  'models.rb',
              File.join(class_path, 'spec/controllers', "#{file_name}_controller_spec.rb")
  end
  
   m.directory File.join('app/models', class_path)
    m.directory File.join('spec/models', class_path)
    # m.directory File.join('spec/fixtures', class_path)

    # Model class, spec and fixtures.
    m.template 'model:model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
    # m.template 'model:fixtures.yml',  File.join('spec/fixtures', class_path, "#{table_name}.yml")
    m.template 'model_spec.rb',       File.join('spec/models', class_path, "#{file_name}_spec.rb")

    unless options[:skip_migration]
      m.migration_template 'model:migration.rb', 'db/migrate', :assigns => {
        :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
      }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
    end
  
  def parts
    # Spec and view template for each action.
    actions.each do |a|
      @action = a
      template 'view_spec.rb', File.join(class_path, 'spec/views', file_name, "#{@action}_view_spec.rb")
      
      template 'view.html.haml', File.join(class_path, 'app/views', file_name, "#{@action}.html.haml")
    end
  end
  
  private
  
  def view_action
    @action
  end
  
  def class_name
    name.classify
  end
  
  def class_path
    "vendor/extensions/#{extension_name.underscore}"
  end
  
  def file_name
    "#{name.underscore}"
  end
  
  def extension_uses_rspec?
    File.exists?(File.join(destination_root, 'spec')) && !options[:with_test_unit]
  end
  
  def class_nesting_depth
    name.count('/') + 1
  end
  
end