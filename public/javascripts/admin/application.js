// Popup Images
Popup.BorderImage            = '/images/admin/popup_border_background.png';
Popup.BorderTopLeftImage     = '/images/admin/popup_border_top_left.png';
Popup.BorderTopRightImage    = '/images/admin/popup_border_top_right.png';
Popup.BorderBottomLeftImage  = '/images/admin/popup_border_bottom_left.png';
Popup.BorderBottomRightImage = '/images/admin/popup_border_bottom_right.png';

// Status Images
Status.SpinnerImage          = '/images/admin/status_spinner.gif';
Status.BackgroundImage       = '/images/admin/status_background.png';
Status.TopLeftImage          = '/images/admin/status_top_left.png';
Status.TopRightImage         = '/images/admin/status_top_right.png';
Status.BottomLeftImage       = '/images/admin/status_bottom_left.png';
Status.BottomRightImage      = '/images/admin/status_bottom_right.png';

Event.addBehavior.reassignAfterAjax = true;

// Behaviors
Event.addBehavior({
  'a.popup': Popup.TriggerBehavior(),
  
  'table#site_map': SiteMapBehavior(),
  
  'input#page_title': function() {
    var title = this;
    var slug = $('page_slug');
    var breadcrumb = $('page_breadcrumb');
    var oldTitle = title.value;
    
    if (!slug || !breadcrumb) return;
    
    new Form.Element.Observer(title, 0.15, function() {
      if (oldTitle.toSlug() == slug.value) slug.value = title.value.toSlug();
      if (oldTitle == breadcrumb.value) breadcrumb.value = title.value;
      oldTitle = title.value;
    });
  },
  
  'div#tab_control': TabControlBehavior(),
  
  'table.index': RuledTableBehavior(),
  
  'form': Status.FormBehavior(),
  
  'form input.activate': function() {
    this.activate();
  },
  
  'form textarea': CodeAreaBehavior(),
  
  'body': ShortcutKeysBehavior
});