require File.dirname(__FILE__) + '/../spec_helper'

describe UserActionObserver do
  dataset :users, :pages_with_layouts, :snippets
  
  before(:each) do
    @user = users(:existing)
    UserActionObserver.current_user = @user
  end
  
  it 'should observe create' do
    [
      User.create!(user_params),
      Page.create!(page_params),
      Layout.create!(layout_params),
      Snippet.create!(snippet_params)
    ].each do |model|
      model.created_by.should == @user
    end
  end
  
  it 'should observe update' do
    [
      users(:existing),
      pages(:home),
      layouts(:main),
      snippets(:first)
    ].each do |model|
      model.attributes = model.attributes.dup
      model.save.should == true
      model.updated_by.should == @user
    end
  end
end