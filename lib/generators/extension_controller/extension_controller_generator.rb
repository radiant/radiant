class ExtensionControllerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  remove_argument :name
  argument :extension_name, :type => :string
  argument :name, :type => :string, :default => :welcome
  argument :actions, :type => :array, :default => [], :banner => "action action"
  class_option :with_test_unit, :type => :boolean, :default => false

  def directories
    empty_directory File.join(class_path, 'app/controllers')
    empty_directory File.join(class_path, 'app/helpers')
    empty_directory File.join(class_path, 'app/views', file_name)

    unless options.with_test_unit?
      empty_directory File.join(class_path, 'spec/controllers')
      empty_directory File.join(class_path, 'spec/helpers')
      empty_directory File.join(class_path, 'spec/views', file_name)
    end
  end


  def files
    template 'controller_spec.rb',
             File.join(class_path, 'spec/controllers', "#{file_name}_controller_spec.rb")

    template 'helper_spec.rb',
             File.join(class_path, 'spec/helpers', "#{file_name}_helper_spec.rb")

    template 'controller.rb',
             File.join(class_path, 'app/controllers', "#{file_name}_controller.rb")

    template 'helper.rb',
             File.join(class_path, 'app/helpers', "#{file_name}_helper.rb")
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