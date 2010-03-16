var ShortcutKeysBehavior = Behavior.create({
  onkeydown: function(event){
    var character = String.fromCharCode(event.keyCode);
    if(!event.shiftKey && !character.blank())
      character = character.toLowerCase();
    if(event.ctrlKey && event.keyCode != 17){
      var button = $$('input[accesskey='+character+']')[0];
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