require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::LayoutController do
  scenario :users, :pages_with_layouts

  before :each do
    login_as :developer
  end

  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Layouts" do
    controller.class.model_class.should == Layout
  end

  { :get => [:index, :new, :edit, :remove],
    :post => [:create],
    :put => [:update],
    :delete => [:destroy] }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action).should require_login }
      end

      it "should allow access to developers for the #{action} action" do
        lambda { 
          send(method, action, :id => layout_id(:main)) 
        }.should restrict_access(:allow => [users(:developer)], 
                                 :url => '/admin/page')
      end

      it "should allow access to admins for the #{action} action" do
        lambda { 
          send(method, action, :id => layout_id(:main)) 
        }.should restrict_access(:allow => [users(:developer)], 
                                 :url => '/admin/page')
      end
      
      it "should deny non-developers and non-admins for the #{action} action" do
        lambda { 
          send(method, action) 
        }.should restrict_access(:deny => [users(:non_admin), users(:existing)],
                                 :url => '/admin/page')
      end
    end
  end

  it "should clear the cache of associated pages when saved" do
    ResponseCache.instance.should_receive(:expire_response).with(pages(:utf8).url)
    put :update, :id => layout_id(:utf8), :layout => {:content_type => "application/xhtml+xml;charset=utf8"}
    response.should be_redirect
  end

end
