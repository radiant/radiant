begin
  require 'git'
rescue LoadError
end

class ExtensionGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :extension_name, :type => :string, :default => 'site'
  
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
    template 'extension.rb',  "#{extension_path}/#{extension_file_name}.rb"
  end
  
  private
  
  def class_name
    "#{extension_name.classify}Extension"
  end
  
  def extension_file_name
    "#{extension_name.underscore}_extension"
  end
  
  def extension_path
    "vendor/extensions/#{extension_name.underscore}"
  end
  
  def homepage
    %x[git config user.name] ? "http://github.com/#{%x[git config user.name].gsub("\n",'')}/radiant-#{extension_file_name}-extension" : "http://yourwebsite.com/#{extension_file_name}"
  end
  
end