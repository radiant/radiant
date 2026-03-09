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
    return false unless @page
    @page.errors[:slug].any? || @page.errors[:breadcrumb].any?
  end

  def default_filter_name
    @page.parts.empty? ? "" : @page.parts[0].filter_id
  end

  def status_to_display
    @page.status_id = 100 if @page.status_id == 90
    @display_status = Status.selectable.map{ |s| [I18n.translate(s.name.downcase), s.id] }
  end

  def clean_page_description(page)
    page.description.to_s.strip.gsub(/\t/,'').gsub(/\s+/,' ')
  end

  def page_edit_javascripts
    <<-CODE
    function addPart(form) {
      if (validPartName()) {
        partLoading();
        var formData = new FormData(form);
        fetch('#{admin_page_parts_path}', {
          method: 'POST',
          body: formData,
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
            'Accept': 'text/html'
          }
        })
        .then(function(response) { return response.text(); })
        .then(function(html) {
          var pages = document.querySelector('#tab_control .pages');
          pages.insertAdjacentHTML('beforeend', html);
          partAdded();
        })
        .catch(function(err) { console.error('addPart error:', err); partAdded(); });
      }
    }
    function removePart() {
      if (confirm('Remove the current part?')) {
        var pages = document.querySelectorAll('#tab_control .pages .page');
        var tabs = document.querySelectorAll('#tab_control .tabs .tab');
        tabs.forEach(function(tab, i) {
          if (tab.classList.contains('here')) {
            if (pages[i]) {
              var destroyInput = pages[i].querySelector('.delete_input');
              if (destroyInput) destroyInput.value = '1';
              pages[i].style.display = 'none';
            }
            tab.remove();
          }
        });
        // Select first remaining tab
        var remainingTabs = document.querySelectorAll('#tab_control .tabs .tab');
        if (remainingTabs.length > 0) {
          var tabControl = document.getElementById('tab_control');
          if (window.selectTab) window.selectTab(tabControl, 0);
        }
      }
    }
    function partAdded() {
      document.getElementById('add_part_busy').style.display = 'none';
      document.getElementById('add_part_button').disabled = false;
      if (window.closePopup) window.closePopup(document.getElementById('add_part_popup'));
      document.getElementById('part_name_field').value = '';
      if (window.refreshTabControl) window.refreshTabControl();
    }
    function partLoading() {
      document.getElementById('add_part_button').disabled = true;
      document.getElementById('add_part_busy').style.display = '';
    }
    function validPartName() {
      var partNameField = document.getElementById('part_name_field');
      var name = partNameField.value.toLowerCase().trim();
      if (name === '') {
        alert('Part name cannot be empty.');
        return false;
      }
      var existingTabs = document.querySelectorAll('#tab_control .tabs .tab');
      for (var i = 0; i < existingTabs.length; i++) {
        if (existingTabs[i].textContent.trim().toLowerCase() === name) {
          alert('Part name must be unique.');
          return false;
        }
      }
      return true;
    }

    var lastPageType = '#{@page.class.name}';
    var tagReferenceWindows = {};
    function loadTagReference(part) {
      var pageType = document.getElementById('page_class_name')?.value || '';
      var url = "#{admin_reference_path('tags')}?class_name=" + encodeURIComponent(pageType);
      fetch(url)
        .then(function(response) { return response.text(); })
        .then(function(html) {
          var existing = document.getElementById('tag_reference_popup');
          if (existing) existing.remove();
          var div = document.createElement('div');
          div.id = 'tag_reference_popup';
          div.innerHTML = html;
          document.body.appendChild(div);
          if (window.initTagFilter) window.initTagFilter();
        });
      lastPageType = pageType;
      return false;
    }

    function addField(form) {
      var formData = new FormData(form);
      fetch('#{admin_page_fields_path}', {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
          'Accept': 'text/html'
        }
      })
      .then(function(response) { return response.text(); })
      .then(function(html) {
        var table = document.querySelector('.drawer_contents table.fieldset');
        if (table) table.insertAdjacentHTML('beforeend', html);
        if (window.closePopup) window.closePopup(document.getElementById('add_field_popup'));
        document.querySelector('#add_field_popup input[type="text"]').value = '';
      });
    }

    function removeField(element) {
      var row = element.closest('tr');
      if (row) {
        var destroyInput = row.querySelector('.delete_input');
        if (destroyInput) destroyInput.value = '1';
        row.style.display = 'none';
      }
    }
    window.removeField = removeField;

    var lastFilter = '#{default_filter_name}';
    function loadFilterReference(part) {
      var filterSelect = document.getElementById("part_" + part + "_filter_id");
      var filter = filterSelect ? filterSelect.value : '';
      if (filter !== '') {
        var url = "#{admin_reference_path('filters')}?filter_name=" + encodeURIComponent(filter);
        fetch(url)
          .then(function(response) { return response.text(); })
          .then(function(html) {
            var existing = document.getElementById('filter_reference_popup');
            if (existing) existing.remove();
            var div = document.createElement('div');
            div.id = 'filter_reference_popup';
            div.innerHTML = html;
            document.body.appendChild(div);
          });
        lastFilter = filter;
      } else {
        alert('No documentation for filter.');
      }
      return false;
    }
    CODE
    .html_safe
  end
end
