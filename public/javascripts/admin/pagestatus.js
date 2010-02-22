PageStatusBehavior = Behavior.create({
  initialize: function(options){},
  onchange: function(event) {
    if( this.element.value >= 90) { 
      $('published_at').removeClassName('hidden') 
    } else { 
      $('published_at').addClassName('hidden');
    }
  }
})