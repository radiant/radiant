module Admin::PagesHelper
  include Admin::NodeHelper
  include Admin::ReferencesHelper
  
  def class_of_page
    @page.class
  end
  
  def filter
    @page.parts.empty? ? nil : @page.parts.first.filter
  end
  
  def meta_errors?
    !!(@page.errors[:slug] or @page.errors[:breadcrumb])
  end

  def default_filter_name
    @page.parts.empty? ? "" : @page.parts[0].filter_id
  end

  def homepage
    @homepage ||= Page.find_by_parent_id(nil)
  end

  def page_edit_javascripts
    <<-CODE
    function addPart(form) {
       if (validPartName()) {
        new Ajax.Updater(
          $('tab_control').down('.pages'),
          '/admin/pages/parts/create/',
          {
            asynchronous: true,
            evalScripts: true,
            insertion: 'bottom',
            onComplete: function(request){ partAdded() },
            onLoading: function(request){ partLoading() },
            parameters: Form.serialize(form)
          }
        );
      }
    }
    function removePart() {
      if(confirm('Remove the current part?')) {
        TabControls['tab_control'].removeSelected();
      }
    }
    function partAdded() {
      var tabControl = TabControls['tab_control'];
      $('add_part_busy').hide();
      $('add_part_button').disabled = false;
      $('add_part_popup').closePopup();
      tabControl.updateTabs();
      tabControl.select(tabControl.tabs.last());
    }
    function partLoading() {
      $('add_part_button').disabled = true;
      $('add_part_busy').appear();
    }
    function validPartName() {
      var partNameField = $('part_name_field');
      var name = partNameField.value.downcase();
      if (name.blank()) {
        alert('Part name cannot be empty.');
        return false;
      }
      if (TabControls['tab_control'].findTabByCaption(name)) {
        alert('Part name must be unique.');
        return false;
      }
      return true;
    }

    var lastPageType = "#{@page.class_name}";
    var tagReferenceWindows = {};
    function loadTagReference(part) {
      var pageType = $F('page_class_name');
      var window = tagReferenceWindows[pageType];
      if (!tagReferenceWindows[pageType])
        tagReferenceWindows[pageType] = new Popup.AjaxWindow("/admin/docs/tags/" + encodeURIComponent(pageType));
      var window = tagReferenceWindows[pageType];
      if(lastPageType != pageType) {
        $('tag_reference_link_' + part).highlight();
        window.show();
      } else {
        window.toggle();
      }
      lastPageType = pageType;
      return false;
    }

    var lastFilter = "#{default_filter_name}";
    var filterWindows = {};
    function loadFilterReference(part) {
      var filter = $F("part_" + part + "_filter_id");
      if (filter != "") {
        if (!filterWindows[filter]) filterWindows[filter] = new Popup.AjaxWindow("/admin/docs/filters/" + encodeURIComponent(filter), {reload: false});
        var window = filterWindows[filter];
        if(lastFilter != filter) {
          window.show();
        } else {
          window.toggle();
        }
        lastFilter = filter;
      } else {
        alert('No documentation for filter.');
      }
      return false;
    }
    CODE
  end
end
