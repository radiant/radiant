// Ensure that relative_url_root is defined
if(typeof(relative_url_root) === 'undefined'){ relative_url_root = ''}

// Popup Images
Popup.BorderImage            = relative_url_root + '/images/admin/popup_border_background.png';
Popup.BorderTopLeftImage     = relative_url_root + '/images/admin/popup_border_top_left.png';
Popup.BorderTopRightImage    = relative_url_root + '/images/admin/popup_border_top_right.png';
Popup.BorderBottomLeftImage  = relative_url_root + '/images/admin/popup_border_bottom_left.png';
Popup.BorderBottomRightImage = relative_url_root + '/images/admin/popup_border_bottom_right.png';

// Status Images
Status.SpinnerImage          = relative_url_root + '/images/admin/status_spinner.gif';
Status.BackgroundImage       = relative_url_root + '/images/admin/status_background.png';
Status.TopLeftImage          = relative_url_root + '/images/admin/status_top_left.png';
Status.TopRightImage         = relative_url_root + '/images/admin/status_top_right.png';
Status.BottomLeftImage       = relative_url_root + '/images/admin/status_bottom_left.png';
Status.BottomRightImage      = relative_url_root + '/images/admin/status_bottom_right.png';

// Status Message Styles
Status.MessageColor = '#e5e5e5';
Status.MessageFontFamily = '"Lucida Grande", "Bitstream Vera Sans", Helvetica, Verdana, Arial, sans-serif';
Status.MessageFontSize = '90%';

// Use Modal Status Windows
Status.Modal = true;
Status.ModalOverlayColor = 'black';
Status.ModalOverlayOpacity = 0.2;

// Reload behaviors for Ajax Requests
Event.addBehavior.reassignAfterAjax = true;

// Wire in Behaviors
Event.addBehavior({
  'body': ShortcutKeysBehavior(),
  
  'a.popup': Popup.TriggerBehavior(),
  
  'a.dropdown': Dropdown.TriggerBehavior(),
  
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
  
  'a.toggle': Toggle.LinkBehavior({
    onLoad: function(link) {
      if (/less/i.match(link.innerHTML)) Toggle.toggle(this.toggleWrappers, this.effect);
    },
    afterToggle: function(link) {
      link.toggleClassName('more');
      link.toggleClassName('less');
      if (/more/i.match(link.innerHTML)) { link.innerHTML = 'Less'; return; }
      if (/less/i.match(link.innerHTML)) { link.innerHTML = 'More'; return; }
    }
  }),
  
  'div#tab_control': TabControlBehavior(),
  
  'table.index': RuledTableBehavior(),
  
  'form': Status.FormBehavior(),
  
  'form input.activate': function() {
    this.activate();
  },
  
  'form textarea': CodeAreaBehavior(),
  
  'input.date': DateInputBehavior(),
  
  'select#page_status_id':  PageStatusBehavior(),
  
  'span.error':  ValidationErrorBehavior()
  
});