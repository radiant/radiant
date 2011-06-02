require File.dirname(__FILE__) + '/../spec_helper'

describe DeprecatedTags do

  before do
    @page = Page.new(:slug => "/", :parent_id => nil, :title => 'Home')
    @keywords = PageField.new(:name => 'Keywords', :content => "Home, Page")
    @description = PageField.new(:name => 'Description', :content => 'The homepage')
    @escaped_keywords = PageField.new(:name => 'Keywords', :content => "sweet & harmonious biscuits")
    @escaped_description = PageField.new(:name => 'Description', :content => 'sweet & harmonious biscuits')
  end
  
  describe "<r:meta>" do
    it "should render <meta> tags for the description and keywords" do
      @page.fields = [@keywords, @description]
      ::ActiveSupport::Deprecation.silence do
        @page.should render('<r:meta/>').as(%{<meta name="description" content="The homepage" /><meta name="keywords" content="Home, Page" />})
      end
    end

    it "should render <meta> tags with escaped values for the description and keywords" do
      @page.fields = [@escaped_keywords, @escaped_description]
      ::ActiveSupport::Deprecation.silence do
        @page.should render('<r:meta/>').as(%{<meta name="description" content="sweet &amp; harmonious biscuits" /><meta name="keywords" content="sweet &amp; harmonious biscuits" />})
      end
    end

    describe "with 'tag' attribute set to 'false'" do
      it "should render the contents of the description and keywords" do
        @page.fields = [@keywords, @description]
        ::ActiveSupport::Deprecation.silence do
          @page.should render('<r:meta tag="false" />').as(%{The homepageHome, Page})
        end
      end

      it "should escape the contents of the description and keywords" do
        @page.fields = [@escaped_keywords, @escaped_description]
        ::ActiveSupport::Deprecation.silence do
          @page.should render('<r:meta tag="false" />').as("sweet &amp; harmonious biscuitssweet &amp; harmonious biscuits")
        end
      end
    end
  end

  describe "<r:meta:description>" do
    it "should render a <meta> tag for the description" do
      @page.fields = [@keywords, @description]
      ::ActiveSupport::Deprecation.silence do
        @page.should render('<r:meta:description/>').as(%{<meta name="description" content="The homepage" />})
      end
    end

    it "should render a <meta> tag with escaped value for the description" do
      @page.fields = [@escaped_keywords, @escaped_description]
      ::ActiveSupport::Deprecation.silence do
        @page.should render('<r:meta:description />').as(%{<meta name="description" content="sweet &amp; harmonious biscuits" />})
      end
    end

    describe "with 'tag' attribute set to 'false'" do
      it "should render the contents of the description" do
        @page.fields = [@keywords, @description]
        ::ActiveSupport::Deprecation.silence do
          @page.should render('<r:meta:description tag="false" />').as(%{The homepage})
        end
      end

      it "should escape the contents of the description" do
        @page.fields = [@escaped_keywords, @escaped_description]
        ::ActiveSupport::Deprecation.silence do
          @page.should render('<r:meta:description tag="false" />').as("sweet &amp; harmonious biscuits")
        end
      end
    end
  end

  describe "<r:meta:keywords>" do
    it "should render a <meta> tag for the keywords" do
      @page.fields = [@keywords, @description]
      ::ActiveSupport::Deprecation.silence do
        @page.should render('<r:meta:keywords/>').as(%{<meta name="keywords" content="Home, Page" />})
      end
    end

    it "should render a <meta> tag with escaped value for the keywords" do
      @page.fields = [@escaped_keywords, @escaped_description]
      ::ActiveSupport::Deprecation.silence do
        @page.should render('<r:meta:keywords />').as(%{<meta name="keywords" content="sweet &amp; harmonious biscuits" />})
      end
    end

    describe "with 'tag' attribute set to 'false'" do
      it "should render the contents of the keywords" do
        @page.fields = [@keywords, @description]
        ::ActiveSupport::Deprecation.silence do
          @page.should render('<r:meta:keywords tag="false" />').as(%{Home, Page})
        end
      end

      it "should escape the contents of the keywords" do
        @page.fields = [@escaped_keywords, @escaped_description]
        ::ActiveSupport::Deprecation.silence do
          @page.should render('<r:meta:keywords tag="false" />').as("sweet &amp; harmonious biscuits")
        end
      end
    end
  end

end