// Based on code from:
//   http://ajaxian.com/archives/handling-tabs-in-textareas
var CodeAreaBehavior = Behavior.create({
  initialize: function() {
    new CodeArea(this.element);
  }
});

var CodeArea = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.element.observe('keydown', this.onkeydown.bind(this));
  },
  
  onkeydown: function(event) {
    // Set desired tab - defaults to two space softtab
    var tab = "  ";
    
    var t = event.target;
    var ss = t.selectionStart;
    var se = t.selectionEnd;
    
    // Tab key - insert tab expansion
    if (event.keyCode == 9) {
      event.preventDefault();
      if (ss != se && t.value.slice(ss,se).indexOf("\n") != -1) {
        // Special case of multi line selection
        // In case selection was not of entire lines (e.g. selection begins in the middle of a line)
        // we ought to tab at the beginning as well as at the start of every following line.
        var pre = t.value.slice(0,ss);
        var sel = t.value.slice(ss,se).replace(/\n/g,"\n"+tab);
        var post = t.value.slice(se,t.value.length);
        t.value = pre.concat(tab).concat(sel).concat(post);
        t.selectionStart = ss + tab.length;
        t.selectionEnd = se + tab.length;
      } else {
        // "Normal" case (no selection or selection on one line only)
        t.value = t.value.slice(0,ss).concat(tab).concat(t.value.slice(ss,t.value.length));
        if (ss == se) {
          t.selectionStart = t.selectionEnd = ss + tab.length;
        } else {
          t.selectionStart = ss + tab.length;
          t.selectionEnd = se + tab.length;
        }
      }
    } else if (event.keyCode == Event.KEY_BACKSPACE && t.value.slice(ss - tab.length,ss) == tab) {
      // Backspace key - delete preceding tab expansion, if exists
      event.preventDefault();
      t.value = t.value.slice(0,ss - tab.length).concat(t.value.slice(ss,t.value.length));
      t.selectionStart = t.selectionEnd = ss - tab.length;
    } else if (event.keyCode == Event.KEY_DELETE && t.value.slice(se,se + tab.length) == tab) {
      // Delete key - delete following tab expansion, if exists
      event.preventDefault();
      t.value = t.value.slice(0,ss).concat(t.value.slice(ss + tab.length,t.value.length));
      t.selectionStart = t.selectionEnd = ss;
    } else if (event.keyCode == Event.KEY_LEFT && t.value.slice(ss - tab.length,ss) == tab) {
      // Left arrow key - move across the tab in one go
      event.preventDefault();
      t.selectionStart = t.selectionEnd = ss - tab.length;
    } else if (event.keyCode == Event.KEY_RIGHT && t.value.slice(ss,ss + tab.length) == tab) {
      // Left/right arrow keys - move across the tab in one go
      event.preventDefault();
      t.selectionStart = t.selectionEnd = ss + tab.length;
    }
  }
});