// Based on code from http://pallieter.org/Projects/insertTab/

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
    var element = this.element;
    var keyCode = event.keyCode ? event.keyCode : event.charCode ? event.charCode : event.which;
    if (keyCode == Event.KEY_TAB && !event.shiftKey && !event.ctrlKey && !event.altKey) {
      var oS = element.scrollTop;
      if (element.setSelectionRange) {
        var sS = element.selectionStart;
        var sE = element.selectionEnd;
        element.value = element.value.substring(0, sS) + "\t" + element.value.substr(sE);
        element.setSelectionRange(sS + 1, sS + 1);
        element.focus();
      }
      else if (element.createTextRange) {
        document.selection.createRange().text = "\t";
        event.returnValue = false;
      }
      element.scrollTop = oS;
      event.stop();
      return false;
    }
    return true;
  }
});