module Admin::LayoutsHelper
  def layout_edit_javascripts
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
    CODE
  end
end
