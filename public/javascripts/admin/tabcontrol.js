var TabControl = Class.create({
  /*
    Initializes a tab control. The variable +element_id+ must be the id of an HTML element
    containing one element with it's class name set to 'tabs' and another element with it's
    class name set to 'pages'.
  */
  initialize: function(element) {
    this.element = $(element);
    this.control_id = this.element.identify();
    TabControl.controls.set(this.control_id, this);
    this.tab_container = this.element.down('.tabs');
    this.tabs = $H();
  },
  
  /*
    Creates a new tab. The variable +tab_id+ is a unique string used to identify the tab
    when calling other methods. The variable +caption+ is a string containing the caption
    of the tab. The variable +page+ is the ID of an HTML element, or the HTML element
    itself. When a tab is initially added the page element is hidden.
  */
  addTab: function(tab_id, caption, page) {
    var tab = new TabControl.Tab(this, tab_id, caption, page);
    
    this.tabs.set(tab.id, tab);
    return this.tab_container.appendChild(tab.createElement());
  },
  
  /*
    Removes +tab+. The variable +tab+ may be either a tab ID or a tab element.
  */
  removeTab: function(tab) {
    if (Object.isString(tab)) tab = this.tabs.get(tab);
    idInput = tab.content.down('.id_input');
    deleteInput = tab.content.down('.delete_input');
    tab.remove();
    this.tabs.unset(tab);
    
    if (this.selected == tab) {
      var first = this.firstTab();
      if (first) this.select(first);
      else this.selected = null;
    }

    deleteInput.setValue('true');
		this.tab_container.appendChild(idInput);
		this.tab_container.appendChild(deleteInput);
  },

  /*
    Selects +tab+ updating the control. The variable +tab+ may be either a tab ID or a
    tab element.
  */
  select: function(tab) {
    if (Object.isString(tab)) tab = this.tabs.get(tab);
    if (this.selected) this.selected.unselect();
    tab.select();
    this.selected = tab;
    var persist = this.pageId() + ':' + this.selected.id;
    document.cookie = "current_tab=" + persist + "; path=/admin";
  },

  /*
    Returns the first tab element that was added using #addTab().
  */
  firstTab: function() {
    return this.tabs.get(this.tabs.keys().first());
  },
  
  /*
    Returns the the last tab element that was added using #addTab().
  */
  lastTab: function() {
    return this.tabs.get(this.tabs.keys().last());
  },
  
  /*
    Returns the total number of tab elements managed by the control.
  */
  tabCount: function() {
    return this.tabs.keys().length;
  },

  autoSelect: function() {
    if (!this.tabs.any()) return; // no tabs in control
    
    var tab, matches = document.cookie.match(/current_tab=(.+?);/);
    if (matches) {
      matches = matches[1].split(':');
      var page = matches[0], tabId = matches[1];
      if (!page || page == this.pageId()) tab = this.tabs.get(tabId);
    }
    this.select(tab || this.firstTab());
  },

  pageId: function() {
    return /(\d+)/.test(window.location.pathname) ? RegExp.$1 : '';
  }
});

TabControl.controls = $H();

TabControl.Tab = Class.create({
  initialize: function(control, id, label, content) {
    this.content = $(content).hide();
    this.label   = label || id;
    this.id      = id;
    this.control = control;
  },

  createElement: function() {
    return this.element = new Element('a', { className: 'tab', href: '#' }).
      update("<span>" + this.label + "</span>").
      observe('click', function(event){
        this.control.select(this.id);
        event.stop();
      }.bindAsEventListener(this));
  },

  select: function() {
    this.content.show();
    this.element.addClassName('here');
  },

  unselect: function() {
    this.content.hide();
    this.element.removeClassName('here');
  },

  remove: function() {
    this.content.remove();
    this.element.stopObserving('click').remove();
  }
});
