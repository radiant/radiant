require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ReferencesHelper do
  describe "determining the page class" do
    before :each do
      helper.send(:instance_variable_set, :@page_class, nil)
    end

    it "should return Page when the class_name was not sent" do
      helper.class_of_page.should == Page
    end

    it "should return the named class when sent class_name" do
      params[:class_name] = "FileNotFoundPage"
      helper.class_of_page.should == FileNotFoundPage
    end

    it "should return Page when the class_name is blank" do
      params[:class_name] = ''
      helper.class_of_page.should == Page
    end
  end

  describe "determining the filter" do
    before :each do
      helper.send(:instance_variable_set, :@filter, nil)
    end

    it "should return nil when no filter is set" do
      helper.filter.should be_nil
    end

    it "should return the filter object for the named filter" do
      params[:filter_name] = "Textile"
      helper.filter.should == TextileFilter
    end

    it "should return nil when the set filter is blank" do
      params[:filter_name] = ' '
      helper.filter.should be_nil
    end
  end

  describe "determining the display name" do
    describe "when getting a filter reference" do
      before :each do
        helper.send(:instance_variable_set, :@filter, nil)
        params[:id] = 'filters'
      end

      it "should return the name of the set filter" do
        params[:filter_name] = "Textile"
        helper._display_name.should == "Textile"
      end

      it "should return <none> when no filter is set" do
        params[:filter_name] = nil
        helper._display_name.should == "<none>"
      end
    end

    describe "when getting a tag reference" do
      before :each do
        helper.send(:instance_variable_set, :@page_class, nil)
        params[:id] = 'tags'
      end

      it "should return the display name of the page class" do
        params[:class_name] = "FileNotFoundPage"
        helper._display_name.should == "File Not Found"
      end

      it "should return Page when <normal> is chosen" do
        params[:class_name] = nil
        helper._display_name.should == "Page"
      end
    end
  end

  describe "rendering the filter reference" do
    before :each do
      helper.send(:instance_variable_set, :@filter, nil)
      params[:id] = 'filters'
      params[:filter_name] = 'Textile'
    end

    it "should render a helpful message when the description is blank" do
      TextileFilter.should_receive(:description).and_return('')
      helper.filter_reference.should == "There is no documentation on this filter."
    end

    it "should render the filter's description when available" do
      helper.filter_reference.should == TextileFilter.description
    end

    it "should render a helpful message when no filter is selected" do
      params[:filter_name] = nil
      helper.filter_reference.should == "There is no filter on the current page part."
    end
  end

  describe "rendering the tag reference" do
    before :each do
      helper.send(:instance_variable_set, :@page_class, nil)
      params[:id] = 'tags'
      params[:class_name] = ''
    end

    it "should render the tag reference partial for each tag description" do
      count = Page.tag_descriptions.size
      helper.should_receive(:render).exactly(count).times.and_return("desc")
      helper.tag_reference.should == "desc" * count
    end
  end
end