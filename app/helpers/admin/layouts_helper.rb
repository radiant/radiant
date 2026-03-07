module Admin::LayoutsHelper
  def layout_edit_javascripts
    <<-CODE
    function loadTagReference() {
      var url = "#{admin_reference_path('tags')}?class_name=" + encodeURIComponent('Page');
      fetch(url)
        .then(function(response) { return response.text(); })
        .then(function(html) {
          var existing = document.getElementById('tag_reference_popup');
          if (existing) { existing.remove(); return; }
          var div = document.createElement('div');
          div.id = 'tag_reference_popup';
          div.innerHTML = html;
          document.body.appendChild(div);
        });
      return false;
    }
    CODE
    .html_safe
  end
end
