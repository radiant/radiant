require_dependency 'application_controller'

class UserSystemExtension < Radiant::Extension
  version "1.0"
  description "Standard user system for Radiant"
  url "http://github.com/radiant/radiant"
  
  def activate
    ApplicationController.class_eval { include LoginSystem }
    Page.class_eval { include UserTags }
    tab "Settings" do
      add_item("Personal", "/admin/preferences/edit", :before => 'Extensions')
      add_item("Users", "/admin/users", :before => 'Extensions')
    end
    Radiant::AdminUI.class_eval { 
      attr_accessor :user
  
      def self.load_default_user_regions
        returning OpenStruct.new do |user|
          user.preferences = Radiant::AdminUI::RegionSet.new do |preferences|
            preferences.main.concat %w{edit_header edit_form}
            preferences.form.concat %w{edit_name edit_email edit_username edit_password edit_locale}
            preferences.form_bottom.concat %w{edit_buttons}
          end
          user.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form}
            edit.form.concat %w{edit_name edit_email edit_username edit_password
                                edit_roles edit_locale edit_notes}
            edit.form_bottom.concat %w{edit_buttons edit_timestamp}
          end
          user.index = Radiant::AdminUI::RegionSet.new do |index|
            index.thead.concat %w{title_header roles_header modify_header}
            index.tbody.concat %w{title_cell roles_cell modify_cell}
            index.bottom.concat %w{new_button}
          end
          user.new = user.edit
        end
      end
    }
    admin.user = Radiant::AdminUI.load_default_user_regions
    UserActionObserver.instance.send :add_observer!, User
  end
end
