module AssetsAdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :asset
      alias_method :assets, :asset
      
      protected

        def load_default_asset_regions
          returning OpenStruct.new do |asset|
            asset.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form assets_container edit_regenerate}
              edit.form.concat %w{edit_title edit_metadata}
              # need to DRY this up...
              edit.bucket_pane.concat %w{bucket_notes bucket bucket_bottom}
              edit.asset_tabs.concat %w{bucket_tab}
            end
            asset.new = asset.edit
            asset.index = Radiant::AdminUI::RegionSet.new do |index|
              index.preamble.concat %w{header explanation new_button filters}
              index.assets_container
              index.bottom.concat %w{regenerate}
              index.thead.concat %w{thumbnail_header title_header content_type_header modify_header}
              index.tbody.concat %w{thumbnail_cell title_cell content_type_cell bucket_cell remove_cell}
              index.bucket_pane.concat %w{bucket_notes bucket bucket_bottom}
              index.asset_tabs.concat %w{bucket_tab}
              index.paginate
            end
            asset.remove = asset.index
            page.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form edit_popups }
              edit.form.concat %w{edit_title edit_extended_metadata edit_page_parts}
              edit.form_bottom.concat %w{edit_buttons}
              edit.parts_bottom.concat %w{edit_layout_and_type edit_timestamp}
              edit.asset_tabs.concat %w{attachment_tab upload_tab bucket_tab search_tab}
              edit.bucket_pane.concat %w{bucket_notes bucket bucket_bottom}
              edit.asset_panes.concat %w{page_attachments upload search}
            end
          end
        end
      
    end
  end
end

