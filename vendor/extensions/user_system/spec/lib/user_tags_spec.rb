require 'spec_helper'

describe "User Tags" do
  dataset :users_and_pages

  describe "<r:author>" do
    it "should render the author of the current page" do
      pages(:home).should render('<r:author />').as('Admin')
    end

    it "should render nothing when the page has no author" do
      pages(:no_user).should render('<r:author />').as('')
    end
  end
    
end