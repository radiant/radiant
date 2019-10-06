// Originally based on code from:
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
    var tabStop = tab.length;
    
    var t = this.element;
    
    if (Prototype.Browser.IE) {
      // Very limited support for IE
      
      if (event.keyCode == Event.KEY_TAB && !event.shiftKey) {
        event.preventDefault();
        document.selection.createRange().text = tab;
      }
      
    } else {
      // Safari and Firefox
      
      // If this is the tab key, make the selection start at the begining and end of lines for
      // multi-line selections
      if (event.keyCode == Event.KEY_TAB) this.normalizeSelection(t);
      
      var ss = t.selectionStart;
      var se = t.selectionEnd;
      
      if (event.keyCode == Event.KEY_TAB) {
        // Tab key
        
        event.preventDefault();
        
        if (event.shiftKey) {
          // Shift + Tab
          
          if (t.value.slice(ss,se).indexOf("\n") != -1) {
            // Special case of multi line selection
            
            var pre = t.value.slice(0, ss);
            var sel = t.value.slice(ss, se);
            var post = t.value.slice(se, t.value.length);
            
            // Back off one tab
            sel = sel.replace(new RegExp("^" + tab, "gm"), '');
            
            // Put everything back together
            t.value = pre.concat(sel).concat(post);
            
            // Readjust the selection
            t.selectionStart = pre.length;
            t.selectionEnd = pre.length + sel.length;
            
          } else {
            // "Normal" case (no selection or selection on one line only)
            
            if (t.value.slice(ss - tabStop, ss) == tab) {
              // Only unindent if there is a tab before the cursor
              
              t.value = t.value.slice(0, ss - tabStop).concat(t.value.slice(ss, t.value.length));
              t.selectionStart = ss - tabStop;
              t.selectionEnd = se - tabStop;
            }
          }
        } else {
          // Tab
          
          if (ss != se && t.value.slice(ss, se).indexOf("\n") != -1) {
            // Special case of multi line selection
            
            // In case selection was not of entire lines (e.g. selection begins in the middle of a line)
            // we ought to tab at the beginning as well as at the start of every following line.
            var pre = t.value.slice(0, ss);
            var sel = t.value.slice(ss, se);
            var post = t.value.slice(se, t.value.length);
            
            // Indent one tab
            sel = sel.replace(/^/gm, tab);
            
            // Put everything back together
            t.value = pre.concat(sel).concat(post);
            
            // Readjust the selection
            t.selectionStart = pre.length;
            t.selectionEnd = pre.length + sel.length;
            
          } else {
            // "Normal" case (no selection or selection on one line only)
            
            t.value = t.value.slice(0, ss).concat(tab).concat(t.value.slice(ss, t.value.length));
            if (ss == se) {
              t.selectionStart = t.selectionEnd = ss + tabStop;
            } else {
              t.selectionStart = ss + tabStop;
              t.selectionEnd = se + tabStop;
            }
          }
        }
      
      } else if (event.keyCode == Event.KEY_BACKSPACE && ss == se && t.value.slice(ss - tabStop, ss) == tab) {
        // Backspace - delete preceding tab expansion, if it exists and nothing is selected
        
        event.preventDefault();
        t.value = t.value.slice(0, ss - tabStop).concat(t.value.slice(ss, t.value.length));
        t.selectionStart = ss - tabStop;
        t.selectionEnd = se - tabStop;
        
      } else if (event.keyCode == Event.KEY_DELETE && t.value.slice(se, se + tabStop) == tab) {
        // Delete key - delete following tab expansion, if exists
        
        event.preventDefault();
        t.value = t.value.slice(0, ss).concat(t.value.slice(ss + tabStop ,t.value.length));
        t.selectionStart = t.selectionEnd = ss;
        
      } else if (event.keyCode == Event.KEY_LEFT && t.value.slice(ss - tabStop, ss) == tab) {
        // Left arrow - move across the tab in one go
        
        event.preventDefault();
        t.selectionStart = t.selectionEnd = ss - tabStop;
      } else if (event.keyCode == Event.KEY_RIGHT && t.value.slice(ss, ss + tabStop) == tab) {
        // Left/right arrow - move across the tab in one go
        
        event.preventDefault();
        t.selectionStart = t.selectionEnd = ss + tabStop;
        
      }
    }
  },
  
  normalizeSelection: function(textarea) {
    var b = 0;
    var value = textarea.value;
    var e = textarea.length;
    var ss = textarea.selectionStart;
    var se = textarea.selectionEnd;
    
    if (ss != se && textarea.value.slice(ss, se).indexOf("\n") != -1) {
      // If multi-line adjust the selection
      
      // If the end of the line is selected back off one character
      if (textarea.value.slice(se - 1, se) == "\n") se = se - 1;
      
      // If the selection does not end with a new line or the end of the document increment until it does
      while ((se < e) && (textarea.value.slice(se, se + 1) != "\n")) se += 1;
      
      // If the selection does not begin at a new line or the begining of the document back off until it does
      while ((ss > b) && (textarea.value.slice(ss - 1, ss) != "\n")) ss -= 1;
      
      textarea.selectionStart = ss;
      textarea.selectionEnd = se;
    }
  }
});