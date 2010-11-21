class LanguageExtensionGenerator < Rails::Generator::NamedBase
  default_options :with_test_unit => false
  
  attr_reader :extension_path, :extension_file_name, :localization_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    @extension_file_name = "#{file_name}_language_pack_extension"
    @extension_path = "vendor/extensions/#{file_name}_language_pack"
    @localization_name = localization_name
  end
  
  def manifest
    record do |m|
      m.directory "#{extension_path}/config/locales"
      m.directory "#{extension_path}/lib/tasks"
      
      m.template 'README',                "#{extension_path}/README"
      m.template 'extension.rb',          "#{extension_path}/#{extension_file_name}.rb"
      # m.template 'tasks.rake',            "#{extension_path}/lib/tasks/#{extension_file_name}_tasks.rake"
      m.template 'lang.yml',              "#{extension_path}/config/locales/#{localization_name}.yml"
      m.template 'available_tags.yml',    "#{extension_path}/config/locales/#{localization_name}_available_tags.yml"
    end
    
  end
  
  def class_name
    super.to_name.gsub(' ', '') + 'LanguagePackExtension'
  end
  
  def extension_name
    class_name.to_name('Extension')
  end
  
  def add_options!(opt)
    # opt.separator ''
    # opt.separator 'Options:'
    # opt.on("--with-test-unit", 
    #        "Use Test::Unit for this extension instead of RSpec") { |v| options[:with_test_unit] = v }
  end
  
  def localization_name
    file_name.split('_')[1] ? "#{file_name.split('_')[0]}-#{file_name.split('_')[1].upcase}" : file_name 
  end
  
  def copy_files
    FileUtils.cp("#{RADIANT_ROOT}/config/locales/en_available_tags.yml","#{RADIANT_ROOT}/#{extension_path}/config/locales/#{localization_name}_available_tags.yml")
  end
end