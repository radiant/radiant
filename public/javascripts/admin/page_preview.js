document.observe('dom:loaded', function() {
  $('show-preview').observe('click', function(e) {
    e.stop();
    
    var form = this.form,
      oldTarget = form.target,
      oldAction = form.action
    
    try {
      var previewer = $('preview_panel').show()
      var frame = $('page-preview')
      $$('div.preview_tools a.cancel, div.preview_tools input').each(function(item, index){
        item.observe('click', function(e){
          if(item.hasClassName('cancel')) {
            previewer.hide()
            frame.src = ''
            e.stop();
          }
        })
      })
      form.target = frame.id
      form.action = '/admin/preview'
      form.submit()
    } finally {
      form.target = oldTarget
      form.action = oldAction
    }
  })
})
