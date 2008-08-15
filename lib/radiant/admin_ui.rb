require 'simpleton'
require 'ostruct'

module Radiant
  class AdminUI
    # This may be loaded before ActiveSupport, so do an explicit require
    require 'radiant/admin_ui/region_set'

    class DuplicateTabNameError < StandardError; end

    class Tab
      attr_accessor :name, :url, :visibility

      def initialize(name, url, options = {})
        @name, @url = name, url
        @visibility = [options[:for], options[:visibility]].flatten.compact
        @visibility = [:all] if @visibility.empty?
      end

      def shown_for?(user)
        visibility.include?(:all) or
          visibility.any? { |role| user.send("#{role}?") }
      end
    end

    class TabSet
      def initialize
        @tabs = []
      end

      def add(name, url, options = {})
        options.symbolize_keys!
        before = options.delete(:before)
        after = options.delete(:after)
        tab_name = before || after
        if self[name]
          raise DuplicateTabNameError.new("duplicate tab name `#{name}'")
        else
          if tab_name
            index = @tabs.index(self[tab_name])
            index += 1 if before.nil?
            @tabs.insert(index, Tab.new(name, url, options))
          else
            @tabs << Tab.new(name, url, options)
          end
        end
      end

      def remove(name)
        @tabs.delete(self[name])
      end

      def size
        @tabs.size
      end

      def [](index)
        if index.kind_of? Integer
          @tabs[index]
        else
          @tabs.find { |tab| tab.name == index }
        end
      end

      def each
        @tabs.each { |t| yield t }
      end

      def clear
        @tabs.clear
      end

      include Enumerable
    end

    include Simpleton

    attr_accessor :tabs

    # Region sets
    attr_accessor :page, :snippet, :layout, :user, :extension

    def initialize
      @tabs = TabSet.new
      load_default_regions
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
                                  edit_page_parts}
            edit.form_bottom.concat %w{edit_buttons}
            edit.parts_bottom.concat %w{edit_layout_and_type edit_timestamp}
        end
        page.index = RegionSet.new do |index|
          index.sitemap_head.concat %w{title_column_header status_column_header
                                      modify_column_header}
          index.node.concat %w{title_column status_column add_child_column remove_column}
        end
        page.remove = page.children = page.index
        page._part = page.edit
      end
    end

    def load_default_user_regions
      returning OpenStruct.new do |user|
        user.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_name edit_email edit_username edit_password
                              edit_roles edit_notes}
          edit.form_bottom.concat %w{edit_timestamp edit_buttons}
        end
        user.index = RegionSet.new do |index|
          index.thead.concat %w{title_header roles_header modify_header}
          index.tbody.concat %w{title_cell roles_cell modify_cell}
          index.bottom.concat %w{new_button}
        end
      end
    end

    def load_default_snippet_regions
      returning OpenStruct.new do |snippet|
        snippet.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_title edit_content edit_filter edit_timestamp}
          edit.form_bottom.concat %w{edit_buttons}
        end
        snippet.index = RegionSet.new do |index|
          index.top.concat %w{help_text}
          index.thead.concat %w{title_header modify_header}
          index.tbody.concat %w{title_cell modify_cell}
          index.bottom.concat %w{new_button}
        end
      end
    end

    def load_default_layout_regions
      returning OpenStruct.new do |layout|
        layout.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_header edit_form}
          edit.form.concat %w{edit_title edit_extended_metadata edit_content edit_timestamp}
          edit.form_bottom.concat %w{edit_buttons}
        end
        layout.index = RegionSet.new do |index|
          index.top.concat %w{help_text}
          index.thead.concat %w{title_header modify_header}
          index.tbody.concat %w{title_cell modify_cell}
          index.bottom.concat %w{new_button}
        end
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