require 'simpleton'
require 'ostruct'

module Radiant
  class AdminUI
    # This may be loaded before ActiveSupport, so do an explicit require
    require 'radiant/admin_ui/region_set'
    
    class DuplicateTabNameError < StandardError; end
    
    # The NavTab Class holds the structure of a navigation tab (including
    # its sub-nav items).
    class NavTab < Array
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
      
      def [](id)
        unless id.kind_of? Fixnum
          self.find {|subnav_item| subnav_item.name.to_s.titleize == id.to_s.titleize }
        else
          super
        end
      end
      
      def <<(*args)
        options = args.extract_options!
        item = args.size > 1 ? deprecated_add(*(args << caller)) : args.first
        raise DuplicateTabNameError.new("duplicate tab name `#{item.name}'") if self[item.name]
        item.tab = self if item.respond_to?(:tab=)
        if options.empty?
          super(item)
        else
          options.symbolize_keys!
          before = options.delete(:before)
          after = options.delete(:after)
          tab_name = before || after
          if self[tab_name]
            _index = index(self[tab_name])
            _index += 1 unless before
            insert(_index, item)
          else
            super(item)
          end
        end
      end
      
      alias :add :<<
      
      def add_item(*args)
        options = args.extract_options!
        options.symbolize_keys!
        before = options.delete(:before)
        after = options.delete(:after)
        tab_name = before || after
        if self[tab_name]
          _index = index(self[tab_name])
          _index += 1 unless before
          insert(_index, NavSubItem.new(args.first, args.second))
        else
          add NavSubItem.new(args.first, args.second)
        end
      end
      
      def visible?(user)
        any? { |sub_item| sub_item.visible?(user) }
      end
      
      def deprecated_add(name, url, caller)
        ActiveSupport::Deprecation.warn("admin.tabs.add is no longer supported in Radiant 0.9.x.  Please update your code to use: \ntab \"Content\" do\n\tadd_item(...)\nend", caller)
        NavSubItem.new(name, url)
      end
    end
    
    # Simple structure for storing the properties of a tab's sub items.
    class NavSubItem
      attr_reader :name, :url
      attr_accessor :tab
      
      def initialize(name, url = "#")
        @name, @url = name, url
      end
      
      def visible?(user)
        visible_by_controller?(user)
      end
      
      def relative_url
        File.join(ActionController::Base.relative_url_root || '', url)
      end
      
      private
      def visible_by_controller?(user)
        params = ActionController::Routing::Routes.recognize_path(url, :method => :get)
        if params && params[:controller]
          klass = "#{params[:controller].camelize}Controller".constantize
          klass.user_has_access_to_action?(user, params[:action])
        else
          false
        end
      end
    end
    
    include Simpleton
    
    attr_accessor :nav
    
    def nav_tab(*args)
      NavTab.new(*args)
    end
    
    def nav_item(*args)
      NavSubItem.new(*args)
    end
    
    def tabs
      nav['Content']
    end
    
    # Region sets
    %w{page snippet layout user configuration extension}.each do |controller|
      attr_accessor controller
      alias_method "#{controller}s", controller
    end
    
    def initialize
      @nav = NavTab.new("Tab Container")
      load_default_regions
    end
    
    def load_default_nav
      content = nav_tab("Content")
      content << nav_item("Pages", "/admin/pages")
      nav << content
      
      design = nav_tab("Design")
      design << nav_item("Layouts", "/admin/layouts")
      design << nav_item("Snippets", "/admin/snippets")
      nav << design
      
      settings = nav_tab("Settings")
      settings << nav_item("General", "/admin/configuration")
      settings << nav_item("Personal", "/admin/preferences")
      settings << nav_item("Users", "/admin/users")
      settings << nav_item("Extensions", "/admin/extensions")
      nav << settings
    end
    
    def load_default_regions
      @page = load_default_page_regions
      @snippet = load_default_snippet_regions
      @layout = load_default_layout_regions
      @user = load_default_user_regions
      @configuration = load_default_configuration_regions
      @extension = load_default_extension_regions
    end
    
    private
    
    def load_default_page_regions
      OpenStruct.new.tap do |page|
        page.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form edit_popups}
          edit.form.concat %w{edit_title edit_extended_metadata edit_page_parts}
          edit.layout.concat %w{edit_layout edit_type edit_status edit_published_at}
          edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        page.index = RegionSet.new do |index|
          index.sitemap_head.concat %w{title_column_header status_column_header actions_column_header}
          index.node.concat %w{title_column status_column actions_column}
        end
        page.remove = page.children = page.index
        page.new = page._part = page.edit
      end
    end
    
    def load_default_user_regions
      OpenStruct.new.tap do |user|
        user.preferences = RegionSet.new do |preferences|
          preferences.main.concat %w{edit_header edit_form}
          preferences.form.concat %w{edit_name edit_email edit_username edit_password edit_locale}
          preferences.form_bottom.concat %w{edit_buttons}
        end
        user.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_name edit_email edit_username edit_password
                              edit_roles edit_locale edit_notes}
          edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        user.index = RegionSet.new do |index|
          index.thead.concat %w{title_header roles_header actions_header}
          index.tbody.concat %w{title_cell roles_cell actions_cell}
          index.bottom.concat %w{new_button}
        end
        user.new = user.edit
      end
    end
    
    def load_default_snippet_regions
      OpenStruct.new.tap do |snippet|
        snippet.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_title edit_content edit_filter}
          edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        snippet.index = RegionSet.new do |index|
          index.top.concat %w{}
          index.thead.concat %w{title_header actions_header}
          index.tbody.concat %w{title_cell actions_cell}
          index.bottom.concat %w{new_button}
        end
        snippet.new = snippet.edit
      end
    end
    
    def load_default_layout_regions
      OpenStruct.new.tap do |layout|
        layout.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_title edit_extended_metadata edit_content}
          edit.form_bottom.concat %w{reference_links edit_buttons edit_timestamp}
        end
        layout.index = RegionSet.new do |index|
          index.top.concat %w{}
          index.thead.concat %w{title_header actions_header}
          index.tbody.concat %w{title_cell actions_cell}
          index.bottom.concat %w{new_button}
        end
        layout.new = layout.edit
      end
    end
    
    def load_default_configuration_regions
      OpenStruct.new.tap do |configuration|
        configuration.show = RegionSet.new do |show|
          show.user.concat %w{preferences}
          show.config.concat %w{site defaults users}
        end
        configuration.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_site edit_defaults edit_users}
          edit.form_bottom.concat %w{edit_buttons}
        end
      end
    end
    
    def load_default_extension_regions
      OpenStruct.new.tap do |extension|
        extension.index = RegionSet.new do |index|
          index.thead.concat %w{title_header website_header version_header}
          index.tbody.concat %w{title_cell website_cell version_cell}
        end
      end
    end
  end
end
