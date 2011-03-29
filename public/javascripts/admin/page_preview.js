document.observe('dom:loaded', function() {
  
  var previewer = $('preview_panel')
  var preview_tools = previewer.down('.preview_tools')
  var frame = $('page-preview')
  var body = document.body
  
  Event.addBehavior({
   "div.preview_tools a.cancel:click" : function(event) {
      previewer.hide()
      body.removeClassName('clipped')
      frame.src = ''
      event.stop()
    },
    "iframe:load" : function(event) {
      preview_tools.style['opacity'] = null
    }
  });
  
  
  $('show-preview').observe('click', function(e) {
    e.stop();
    
    var form = this.form,
      oldTarget = form.target,
      oldAction = form.action
    
    try {
      $(body).scrollTo()
      previewer.show()
      preview_tools.style['opacity'] = 1
      body.addClassName('clipped')
      form.target = frame.id
      form.action = '/admin/preview'
      form.submit()
    } finally {
      form.target = oldTarget
      form.action = oldAction
    }
  })
})
