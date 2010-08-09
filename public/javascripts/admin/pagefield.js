function addField(form) {
  if (validFieldName()) {
    new Ajax.Updater(
      $('attributes').down('tbody'),
      '/admin/page_fields/',
      {
        asynchronous: true,
        evalScripts: true,
        insertion: 'bottom',
        onComplete: function(response){ fieldAdded(form); },
        onLoading: function(request){ fieldLoading(form); },
        parameters: Form.serialize(form)
      }
    );
  }
}
function removeField(button) {
  var row = $(button).up('tr');
  var name = row.down('label').innerHTML;
  if (confirm('Remove the "' + name + '" field?')) {
    row.down('.delete_input').setValue(true);
    row.down('.page_field_name').clear();
    row.hide();
  }
}
function fieldAdded(element) {
  $(element).previous('.busy').hide();
  $(element).down('.button').enable();
  $(element).up('.popup').closePopup();
  var field_index = $('page_field_counter').value;
  $('page_fields_attributes_' + field_index + '_content').focus();
  $('page_field_counter').setValue(Number(field_index).succ());
  $('new_page_field').reset();
}
function fieldLoading(element) {
  $(element).down('.button').disable();
  $(element).previous('.busy').appear();
}
function validFieldName() {
  var fieldName = $('page_field_name');
  var name = fieldName.value.downcase();
  if (name.blank()) {
    alert('Field name cannot be empty.');
    return false;
  }
  if (findFieldByName(name)) {
    alert('Field name must be unique.');
    return false;
  }
  return true;
}
function findFieldByName(name) {
  return $('attributes').select('input.page_field_name').detect(function(input) { return input.value.downcase() == name; });
}