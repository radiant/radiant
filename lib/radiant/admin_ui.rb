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
      attr_reader :name, :proper_name, :visibility

      def initialize(name, proper_name, visibility = [:all])
        @name, @proper_name, @visibility = name, proper_name, Array(visibility)
      end

      def [](id)
        unless id.kind_of? Fixnum
          self.find {|subnav_item| subnav_item.name.to_s == id.to_s }
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

      def visible?(user)
        visibility.include?(:all) || visibility.any? {|v| user.has_role?(v) }
      end

      def deprecated_add(name, url, caller)
        ActiveSupport::Deprecation.warn("admin.tabs.add is no longer supported in Radiant 0.9+.  Please update your code to use admin.nav", caller)
        NavSubItem.new(name.underscore.to_sym, name, url)
      end
    end

    # Simple structure for storing the properties of a tab's sub items.
    class NavSubItem
      attr_reader :name, :proper_name, :url
      attr_accessor :tab

      def initialize(name, proper_name, url = "#")
        @name, @proper_name, @url = name, proper_name, url
      end

      def visible?(user)
        tab.visible?(user) && visible_by_controller?(user)
      end

      def relative_url
        File.join(ActionController::Base.relative_url_root || '', url)
      end
      
      private
      def visible_by_controller?(user)
        params = ActionController::Routing::Routes.recognize_path(url, :method => :get)
        if params && params[:controller]
          controller = "#{params[:controller].camelize}Controller".constantize
          controller.new.send(:user_has_access_to_action?, params[:action])
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
      nav[:content]
    end

    # Region sets
    %w{page snippet layout user extension}.each do |controller|
      attr_accessor controller
      alias_method "#{controller}s", controller
    end

    def initialize
      @nav = NavTab.new(:tabs, "Tab Container")
      load_default_regions
    end

    def load_default_nav
      content = nav_tab(:content, "Content")
      content << nav_item(:pages, "Pages", "/admin/pages")
      content << nav_item(:snippets, "Snippets", "/admin/snippets")
      nav << content

      design = nav_tab(:design, "Design", [:developer])
      design << nav_item(:layouts, "Layouts", "/admin/layouts")
      nav << design

      # media = NavTab.new(:assets, "Assets")
      # media << NavSubItem.new(:all, "All", "/admin/assets/")
      # media << NavSubItem.new(:all, "Unattached", "/admin/assets/unattached/")

      settings = nav_tab(:settings, "Settings")
      settings << nav_item(:general, "Personal", "/admin/preferences/edit")
      settings << nav_item(:users, "Users", "/admin/users")
      settings << nav_item(:extensions, "Extensions", "/admin/extensions")
      nav << settings
    end

    def load_default_regions
      @page = load_default_page_regions
      @snippet = load_default_snippet_regions
      @layout = load_default_layout_regions
      @user = load_default_user_regions
      @extension = load_default_extension_regions
    end

    private

    def load_default_page_regions
      returning OpenStruct.new do |page|
        page.edit = RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form edit_popups}
            edit.form.concat %w{edit_title edit_extended_metadata
                                  edit_page_parts edit_layout_and_type}
            edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        page.index = RegionSet.new do |index|
          index.sitemap_head.concat %w{title_column_header status_column_header
                                      modify_column_header}
          index.node.concat %w{title_column status_column add_child_column remove_column}
        end
        page.remove = page.children = page.index
        page.new = page._part = page.edit
      end
    end

    def load_default_user_regions
      returning OpenStruct.new do |user|
        user.preferences = RegionSet.new do |preferences|
          preferences.main.concat %w{edit_header edit_form}
          preferences.form.concat %w{edit_name edit_email edit_username edit_password}
          preferences.form_bottom.concat %w{edit_buttons}
        end
        user.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_name edit_email edit_username edit_password
                              edit_roles edit_notes}
          edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        user.index = RegionSet.new do |index|
          index.thead.concat %w{title_header roles_header modify_header}
          index.tbody.concat %w{title_cell roles_cell modify_cell}
          index.bottom.concat %w{new_button}
        end
        user.new = user.edit
      end
    end

    def load_default_snippet_regions
      returning OpenStruct.new do |snippet|
        snippet.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_title edit_content edit_filter}
          edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        snippet.index = RegionSet.new do |index|
          index.top.concat %w{help_text}
          index.thead.concat %w{title_header modify_header}
          index.tbody.concat %w{title_cell modify_cell}
          index.bottom.concat %w{new_button}
        end
        snippet.new = snippet.edit
      end
    end

    def load_default_layout_regions
      returning OpenStruct.new do |layout|
        layout.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_title edit_extended_metadata edit_content}
          edit.form_bottom.concat %w{edit_buttons edit_timestamp}
        end
        layout.index = RegionSet.new do |index|
          index.top.concat %w{help_text}
          index.thead.concat %w{title_header modify_header}
          index.tbody.concat %w{title_cell modify_cell}
          index.bottom.concat %w{new_button}
        end
        layout.new = layout.edit
      end
    end

    def load_default_extension_regions
      returning OpenStruct.new do |extension|
        extension.index = RegionSet.new do |index|
          index.thead.concat %w{title_header website_header version_header}
          index.tbody.concat %w{title_cell website_cell version_cell}
        end
      end
    end
  end
end
