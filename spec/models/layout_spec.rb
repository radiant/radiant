require File.dirname(__FILE__) + '/../spec_helper'

describe Layout do
  dataset :layouts
  test_helper :validations
  
  before :each do
    @layout = @model = Layout.new(layout_params)
  end
  
  it 'should validate presence of' do
    assert_valid :name, 'Just a Test'
    assert_invalid :name, 'this must not be blank', nil, '', '  '
  end
  
  it 'should validate uniqueness of' do
    assert_invalid :name, 'this name is already in use', 'Main'
    assert_valid :name, 'Something Else'
  end
  
  it 'should validate length of' do
    {
      :name => 100
    }.each do |field, max|
      assert_invalid field, ('this must not be longer than %d characters' % max), 'x' * (max + 1)
      assert_valid field, 'x' * max
    end
  end
end
