# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class ExtensionManagerExtension < Radiant::Extension
  version "1.0"
  description "Standard view of extensions"
  url "http://github.com/radiant/radiant-extension_manager-extension"
  
  def activate
    tab 'Settings' do
      add_item "Extensions", "/admin/extensions"
    end
    
    Radiant::AdminUI.class_eval { 
      attr_accessor :extensions
  
      def load_default_extension_regions
        returning OpenStruct.new do |extension|
          extension.index = Radiant::AdminUI::RegionSet.new do |index|
            index.thead.concat %w{title_header website_header version_header}
            index.tbody.concat %w{title_cell website_cell version_cell}
          end
        end
      end
    }
    admin.extensions = Radiant::AdminUI.load_default_extension_regions
  end
end
