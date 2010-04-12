require "spec_helper"

describe Radiant::AdminUI do
  subject do
    admin = Radiant::AdminUI.instance
    admin.user = Radiant::AdminUI.load_default_user_regions
    admin
  end
  let(:admin){subject}
  
  it { should respond_to('user') }
  it { should respond_to('users') }
  specify { admin.user.should_not be_nil }
  specify { admin.user.should be_kind_of(OpenStruct) }
  specify { admin.user.edit.should_not be_nil }
  specify { admin.user.edit.main.should == %w{edit_header edit_form}}
  specify { admin.user.edit.form.should == %w{edit_name edit_email edit_username
                                              edit_password edit_roles edit_locale edit_notes}}
  specify { admin.user.edit.form_bottom.should == %w{edit_buttons edit_timestamp}}
  specify { admin.user.index.should_not be_nil }
  specify { admin.user.index.thead.should == %w{title_header roles_header modify_header} }
  specify { admin.user.index.tbody.should == %w{title_cell roles_cell modify_cell} }
  specify { admin.user.index.bottom.should == %w{new_button} }
  specify { admin.user.preferences.main.should == %w{edit_header edit_form} }
  specify { admin.user.preferences.form.should == %w{edit_name edit_email edit_username edit_password edit_locale} }
  specify { admin.user.preferences.form_bottom.should == %w{edit_buttons} }
  
  specify { admin.user.new.should == admin.user.edit }
end

