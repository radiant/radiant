require 'rails_generator/base'
require 'rails_generator/generators/components/mailer/mailer_generator'

class ExtensionMailerGenerator < MailerGenerator
  
  attr_accessor :extension_name
  default_options :with_test_unit => false
  
  def initialize(runtime_args, runtime_options = {})
    runtime_args = runtime_args.dup
    @extension_name = runtime_args.shift
    super(runtime_args, runtime_options)
  end
  
  def manifest
    if extension_uses_rspec?
      rspec_manifest
    else
      super
    end
  end
  
  def rspec_manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Mailer, view, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('app/views', file_path)

      # Mailer class and unit test.
      m.template "mailer:mailer.rb",    File.join('app/models', class_path, "#{file_name}.rb")

      # View template and fixture for each action.
      actions.each do |action|
        relative_path = File.join(file_path, action)
        view_path     = File.join('app/views', "#{relative_path}.erb")

        m.template "mailer:view.erb", view_path,
                   :assigns => { :action => action, :path => view_path }
      end
    end
  end
  
  def banner
    "Usage: #{$0} #{spec.name} ExtensionName #{spec.name.camelize}Name [options]"
  end
  
  def extension_path
    File.join('vendor', 'extensions', @extension_name.underscore)
  end
  
  def destination_root
    File.join(RAILS_ROOT, extension_path)
  end
  
  def extension_uses_rspec?
    File.exists?(File.join(destination_root, 'spec')) && !options[:with_test_unit]
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--with-test-unit", 
           "Use Test::Unit tests instead sof RSpec.") { |v| options[:with_test_unit] = v }
  end
end
