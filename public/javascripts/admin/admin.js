document.observe('dom:loaded', function() {
  
  when('table.index', function(table){
    if(table.identify() == 'site-map')
      new SiteMap(table);
    else
      new RuledTable(table);
  });
  
  when('page_title', function(title) {
    var slug = $('page_slug'),
        breadcrumb = $('page_breadcrumb'),
        oldTitle = title.value;

    if (!slug || !breadcrumb) return;

    new Form.Element.Observer(title, 0.15, function() {
      if (oldTitle.toSlug() == slug.value) slug.value = title.value.toSlug();
      if (oldTitle == breadcrumb.value) breadcrumb.value = title.value;
      oldTitle = title.value;
    });
  });

  when('tab-control', function(element) {
    tabControl = new TabControl(element);

    $$('#pages div.part > input[type=hidden]:first-child').each(function(part, index) {
      var page = part.up('.page');
      tabControl.addTab('tab-' + (index + 1), part.value, page.id);
    });

    tabControl.autoSelect();
  });

  when('tag-reference-popup', function(popup) {
    var tags, searchingOn = "";

    new Form.Element.Observer('search-tag-reference', 0.5, function(element, value) {
      if (!tags) tags = popup.select('.tag-description')

      if (value.length < 3 && searchingOn != "") {
        searchingOn = "";
        tags.invoke('show');
      } else if (value.length >= 3 && searchingOn != value) {
        searchingOn = value
        tags.each(function(div) {
          div[div.hasWord(value) ? 'show' : 'hide']();
        });
      }
    });
  });

  when($$('.popup p a.close'), function(links){
    links.invoke('observe', 'click', function(e) {
      e.findElement('.popup').hide();
      e.stop();
    });
  });
  
  when('publication-date', function(pub_date){
    if($('page_status_id')) {
      if($F('page_status_id') == '100')
        $('publication-date').show().select('select').invoke('enable');

      $('page_status_id').observe('change', function(){
        if($F(this) == '100')
          $('publication-date').show().select('select').invoke('enable');
        else
          $('publication-date').hide().select('select').invoke('disable');
      })
    }
  });

  when('notice', function(notice) {
    new Effect.Fade(notice, {delay: 3});
  });

});

Element.addMethods({
  hasWord: function(element, word) {
    element = $(element);
    if (element.nodeType == Node.TEXT_NODE) {
      return element.nodeValue.include(word);
    } else {
      return $A(element.childNodes).any(function(child) {
        return Element.hasWord(child, word);
      });
    }
  }
})

// When object is available, do function fn.
function when(obj, fn) {
  if (Object.isString(obj)) obj = /^[\w-]+$/.test(obj) ? $(obj) : $(document.body).down(obj);
  if (Object.isArray(obj) && !obj.length) return;
  if (obj) fn(obj);
}

function part_added() {
  var partName = $F('part-name-field');
  var tab = 'tab-' + partName.toSlug();
  var page = 'page-' + partName.toSlug();
  tabControl.addTab(tab, partName, page);
  $('add-part-popup').hide();
  $('busy').hide();
  $('part-name-field').value = '';
  $('add-part-button').enable();
  $('page-part-index-field').value = parseInt($('page-part-index-field').value) + 1;
  $(page).down('textarea').focus();
  tabControl.select(tab);
}
function part_loading() {
  $('add-part-button').disable();
  $('busy').appear();
}
function valid_part_name() {
  var partNameField = $('part-name-field');
  var name = partNameField.value.downcase().strip();
  var result = true;
  if (name == '') {
    alert('Part name cannot be empty.');
    return false;
  }
  tabControl.tabs.each(function(pair){
    if (tabControl.tabs.get(pair.key).caption == name) {
      result = false;
      alert('Part name must be unique.');
      throw $break;
    }
  })
  return result;
}
function center(element) {
  var header = $('header')
  element = $(element);
  element.style.position = 'absolute';
  var dim = Element.getDimensions(element);
  var top = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop;
  element.style.top = (top + 200) + 'px';
  element.style.left = ((header.offsetWidth - dim.width) / 2) + 'px';
}
function toggle_add_part_popup() {
  var popup = $('add-part-popup');
  var partNameField = $('part-name-field');
  center(popup);
  Element.toggle(popup);
  Field.focus(partNameField);
}
