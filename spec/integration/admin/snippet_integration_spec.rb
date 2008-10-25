require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Snippets' do
  scenario :users
  
  before do
    login :admin
  end
  
  it 'should be able to go to snippets tab' do
    click_on :link => '/admin/snippets'
  end
  
  it 'should be able to create a new snippet' do
    navigate_to '/admin/snippets/new'
    lambda do
      submit_form :snippet => {:name => 'Mine', :content => 'Me Snippet'}
    end.should change(Snippet, :count).by(1)
  end
end