class ExtensionGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :extension_name, :type => :string, :default => 'site'
  class_option :with_test_unit, :type => :boolean, :default => false
  
  def directories
    empty_directory "#{extension_path}/app/controllers"
    empty_directory "#{extension_path}/app/helpers"
    empty_directory "#{extension_path}/app/models"
    empty_directory "#{extension_path}/app/views"
    empty_directory "#{extension_path}/config/locales"
    empty_directory "#{extension_path}/db/migrate"
    empty_directory "#{extension_path}/lib/tasks"
  end
  
  def templates
    template 'README.md',     "#{extension_path}/README.md"
    template 'VERSION',       "#{extension_path}/VERSION"
    template 'extension.rb',  "#{extension_path}/#{file_name}.rb"
    template 'tasks.rake',    "#{extension_path}/lib/tasks/#{file_name}_tasks.rake"
    template 'en.yml',        "#{extension_path}/config/locales/en.yml"
    template 'routes.rb',     "#{extension_path}/config/routes.rb"
  end
  
  def rspec
    unless options.with_test_unit?
      empty_directory "#{extension_path}/spec/controllers"
      empty_directory "#{extension_path}/spec/models"        
      empty_directory "#{extension_path}/spec/views"
      empty_directory "#{extension_path}/spec/helpers"
      empty_directory "#{extension_path}/features/support"
      empty_directory "#{extension_path}/features/step_definitions/admin"
      
      template  'rspec/Rakefile',          "#{extension_path}/Rakefile"
      template  'rspec/spec_helper.rb',    "#{extension_path}/spec/spec_helper.rb"
      copy_file 'rspec/_.rspec',           "#{extension_path}/spec/.rspec"
      copy_file 'rspec/cucumber.yml',      "#{extension_path}/cucumber.yml"
      template  'rspec/cucumber_env.rb',   "#{extension_path}/features/support/env.rb"
      template  'rspec/cucumber_paths.rb', "#{extension_path}/features/support/paths.rb"
    end
  end
  
  def testunit
    if options.with_test_unit?
      empty_directory "#{extension_path}/test/fixtures"
      empty_directory "#{extension_path}/test/functional"
      empty_directory "#{extension_path}/test/unit"
      
      template 'test/Rakefile',            "#{extension_path}/Rakefile"
      template 'test/test_helper.rb',      "#{extension_path}/test/test_helper.rb"
      template 'test/functional_test.rb',  "#{extension_path}/test/functional/#{extension_file_name}_test.rb"
    end
  end
  
  
  private
  
  def class_name
    "#{extension_name.classify}Extension"
  end
  
  def file_name
    "#{extension_name.underscore}_extension"
  end
  
  def extension_path
    "vendor/extensions/#{extension_name.underscore}"
  end
  
  def homepage
    author_name ? "http://github.com/#{author_name}/radiant-#{file_name}-extension" : "http://yourwebsite.com/#{file_name}"
  end
  
  def author_info
    @author_info ||= begin
      Git.global_config
    rescue NameError
      {}
    end
  end

  def homepage
    author_info['github.user'] ? "http://github.com/#{author_info['github.user']}/radiant-#{file_name}-extension" : "http://yourwebsite.com/#{file_name}"
  end

  def author_email
    author_info['user.email'] || 'your email'
  end

  def author_name
    author_info['user.name'] || 'Your Name'
  end
  
end