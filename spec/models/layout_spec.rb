require File.dirname(__FILE__) + '/../spec_helper'

describe Layout do
  dataset :layouts
  test_helper :validations
  
  before :each do
    @layout = @model = Layout.new(layout_params)
  end
  
  it 'should validate presence of' do
    assert_valid :name, 'Just a Test'
    assert_invalid :name, 'required', nil, '', '  '
  end
  
  it 'should validate uniqueness of' do
    assert_invalid :name, 'name already in use', 'Main'
    assert_valid :name, 'Something Else'
  end
  
  it 'should validate length of' do
    {
      :name => 100
    }.each do |field, max|
      assert_invalid field, ('%d-character limit' % max), 'x' * (max + 1)
      assert_valid field, 'x' * max
    end
  end
end
