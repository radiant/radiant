var ShortcutKeysBehavior = Behavior.create({
  onkeydown: function(event){
    var character = String.fromCharCode(event.keyCode);
    if(!event.shiftKey && !character.blank())
      character = character.toLowerCase();
    // Blindly passing RIGHT_ARROW through fromCharCode() returns a single-quote character (ascii decimal 39).
    // I suspect that causes a bad string interpolation when evaluating `button`.
    // Adding double-quotes to the accesskey spec seems to fix it.
    // Now of course now keyCode 34 (double-quote in ascii decimal) will cause a problem... but your browser will likely catch Ctrl+PgDn anyway
    // We should only evaluate keyCodes that can come from printable characters, now sure how feasible that is.
    // Eg. http://www.cambiaresearch.com/articles/15/javascript-char-codes-key-codes
    if(event.ctrlKey && event.keyCode != 17){
      var button = $$('input[accesskey="'+character+'"]')[0];
      if(button){
        event.stop();
        button.click();
      } else {
        var control = TabControls['tab_control'];
        if(event.keyCode == 219){ // [
          control.selectPreviousTab();
        }
        if(event.keyCode == 221){ // ]
          control.selectNextTab();
        }
        if(event.keyCode >= 49 && event.keyCode <= 57){ // 1..9
          var index = event.keyCode - 49;
          control.selectTabByIndex(index);
          event.stop();
        } 
      }
    }
  }
});