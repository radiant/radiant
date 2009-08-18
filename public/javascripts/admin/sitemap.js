/*
 *  sitemap.js
 *  
 *  depends on: prototype.js and lowpro.js
 *  
 *  Used by Radiant to create the expandable sitemap.
 *  
 *  To use, simply add the following lines to application.js:
 *  
 *     Event.addBehavior({
 *       'table#site_map': SiteMapBehavior()
 *     });
 *
 */

var SiteMapBehavior = Behavior.create({
  
  initialize: function() {
    this.readExpandedCookie();
  },
  
  onclick: function(event) {
    if (this.isExpander(event.target)) {
      var row = event.findElement('tr');
      if (this.hasChildren(row)) {
        this.toggleBranch(row, event.target);
      }
    }
  },
  
  hasChildren: function(row) {
    return !row.hasClassName('no_children');
  },
  
  isExpander: function(element) {
    return element.match('img.expander');
  },
  
  isExpanded: function(row) {
    return row.hasClassName('children_visible');
  },
  
  isRow: function(element) {
    return element && element.tagName && element.match('tr');
  },
  
  extractLevel: function(row) {
    if (/level_(\d+)/i.test(row.className))
      return RegExp.$1.toInteger();
  },
  
  extractPageId: function(row) {
    if (/page_(\d+)/i.test(row.id))
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
      row.removeClassName('children_visible');
      row.addClassName('children_hidden');
      this.persistCollapsed(row);
    } else {
      img.src = img.src.replace('expand', 'collapse');
      row.removeClassName('children_hidden');
      row.addClassName('children_visible');
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
    console.log('hello!');
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
    var id = this.extractPageId(row);
    var level = this.extractLevel(row);
    var spinner = $('busy_' + id);
        
    new Ajax.Updater(
      row,
      '../admin/ui/pages/children/' + id + '/' + level,
      {
        insertion: "after",
        onLoading:  function() { spinner.show(); this.updating = true  }.bind(this),
        onComplete: function() { spinner.fade(); this.updating = false }.bind(this)
      }
    );
  },
  
  toggleBranch: function(row, img) {
    if (!this.updating) {
      if (this.isExpanded(row)) {
        this.hideBranch(row, img);
      } else {
        this.showBranch(row, img);
      }
    }
  }
});
