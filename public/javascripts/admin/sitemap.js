var SiteMap = Class.create(RuledTable, {
  initialize: function($super, element) {
    $super(element);
    this.readExpandedCookie();
    Event.observe(element, 'click', this.onMouseClickRow.bindAsEventListener(this));
  },
  
  onMouseClickRow: function(event) {
    if (this.isExpander(event.target)) {
      var row = event.findElement('tr');
      if (this.hasChildren(row)) {
        this.toggleBranch(row, event.target);
      }
    }
  },
  
  hasChildren: function(row) {
    return !row.hasClassName('no-children');
  },
  
  isExpander: function(element) {
    return element.match('img.expander');
  },
  
  isExpanded: function(row) {
    return row.hasClassName('children-visible');
  },
  
  isRow: function(element) {
    return element && element.tagName && element.match('tr');
  },
  
  extractLevel: function(row) {
    if (/level-(\d+)/i.test(row.className))
      return RegExp.$1.toInteger();
  },
  
  extractPageId: function(row) {
    if (/page-(\d+)/i.test(row.id))
      return RegExp.$1.toInteger();
  },
  
  getExpanderImageForRow: function(row) {
    return row.down('img');
  },
  
  readExpandedCookie: function() {
    var matches = document.cookie.match(/expanded_rows=(.+?);/);
    this.expandedRows = matches ? decodeURIComponent(matches[1]).split(',') : [];
  },

  saveExpandedCookie: function() {
    document.cookie = "expanded_rows=" + encodeURIComponent(this.expandedRows.uniq().join(",")) + "; path=/admin";
  }, 

  persistCollapsed: function(row) {
    var pageId = this.extractPageId(row);
    this.expandedRows = this.expandedRows.without(pageId);
    this.saveExpandedCookie();
  },

  persistExpanded: function(row) {
    this.expandedRows.push(this.extractPageId(row));
    this.saveExpandedCookie();
  },

  toggleExpanded: function(row, img) {
    if (!img) img = this.getExpanderImageForRow(row);
    if (this.isExpanded(row)) {
      img.src = img.src.replace('collapse', 'expand');
      row.removeClassName('children-visible');
      row.addClassName('children-hidden');
      this.persistCollapsed(row);
    } else {
      img.src = img.src.replace('expand', 'collapse');
      row.removeClassName('children-hidden');
      row.addClassName('children-visible');
      this.persistExpanded(row);
    }
  },
  
  hideBranch: function(parent, img) {
    var level = this.extractLevel(parent), row = parent.next();
    while (this.isRow(row) && this.extractLevel(row) > level) {
      row.hide();
      row = row.next();
    }
    this.toggleExpanded(parent, img);
  },
  
  showBranch: function(parent, img) {
    var level = this.extractLevel(parent), row = parent.next(),
        children = false, expandLevels = [level + 1];
        
    while (this.isRow(row)) {
      var currentLevel = this.extractLevel(row);
      if (currentLevel <= level) break;
      children = true;
      if (currentLevel < expandLevels.last()) expandLevels.pop();
      if (expandLevels.include(currentLevel)) {
        row.show();
        if (this.isExpanded(row)) expandLevels.push(currentLevel + 1);
      }
      row = row.next();
    }
    if (!children) this.getBranch(parent);
    this.toggleExpanded(parent, img);
  },
  
  getBranch: function(row) {
    var id = this.extractPageId(row), level = this.extractLevel(row),
        spinner = $('busy-' + id);
        
    new Ajax.Updater(
      row,
      '/admin/pages/' + id + '/children?level=' + level,
      {
        insertion: "after",
        onLoading:  function() { spinner.show(); this.updating = true  }.bind(this),
        onComplete: function() { spinner.fade(); this.updating = false }.bind(this),
        method: 'get'
      }
    );
  },
  
  toggleBranch: function(row, img) {
    if (!this.updating) {
      var method = (this.isExpanded(row) ? 'hide' : 'show') + 'Branch';
      this[method](row, img);
    }
  }
});
