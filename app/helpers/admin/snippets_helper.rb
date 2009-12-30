module Admin::SnippetsHelper
  def snippet_edit_javascripts
    <<-CODE
    
    var tagReferenceWindows = {};
    function loadTagReference() {
      var pageType = 'Page';
      if (!tagReferenceWindows[pageType])
        tagReferenceWindows[pageType] = new Popup.AjaxWindow("#{admin_reference_path('tags')}?class_name=" + encodeURIComponent(pageType), {reload: false});
      var window = tagReferenceWindows[pageType];
      if('Page' != pageType) {
        $('tag_reference_link').highlight();
        window.show();
      } else {
        window.toggle();
      }
      lastPageType = pageType;
      return false;
    }

    var lastFilter = '#{@snippet.filter_id}';
    var filterWindows = {};
    function loadFilterReference() {
      var filter = $F("snippet_filter_id");
      if (filter != "") {
        if (!filterWindows[filter]) filterWindows[filter] = new Popup.AjaxWindow("#{admin_reference_path('filters')}?filter_name="+encodeURIComponent(filter), {reload: false});
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
