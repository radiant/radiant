require File.dirname(__FILE__) + '/../spec_helper'

describe DeprecatedTags do

  before do
    @page = Page.new(:slug => "/", :parent_id => nil, :title => 'Home')
    @keywords = PageField.new(:name => 'Keywords', :content => "Home, Page")
    @description = PageField.new(:name => 'Description', :content => 'The homepage')
    @escaped_keywords = PageField.new(:name => 'Keywords', :content => "sweet & harmonious biscuits")
    @escaped_description = PageField.new(:name => 'Description', :content => 'sweet & harmonious biscuits')
  end

  describe "<r:navigation>" do
      it "should render with deprecated url attribute" do
      ::ActiveSupport::Deprecation.silence do
        lambda {
          @page.should render(%{
<r:navigation urls="test:/test">
  <r:normal><li><a href="<r:url/>"><r:title/></a></li></r:normal>
  <r:selected><li><a class="current" href="<r:url/>"><r:title/></a></li></r:selected>
  <r:between></r:between>
</r:navigation>}).as(%{
<li><a href="/test">test</a></li>})
        }.should_not raise_error
      end
    end
  end
end
