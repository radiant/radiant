require 'spec_helper'

describe Radiant::Admin::ReferencesHelper do
  class BasicFilter < TextFilter; end
  class CustomFilter < TextFilter
    filter_name "Really Custom"
  end

  describe "determining the page class" do
    before :each do
      helper.send(:instance_variable_set, :@page_class, nil)
    end

    it "should return Page when the class_name was not sent" do
      expect(helper.class_of_page).to eq(Page)
    end

    it "should return the named class when sent class_name" do
      params[:class_name] = "FileNotFoundPage"
      expect(helper.class_of_page).to eq(FileNotFoundPage)
    end

    it "should return Page when the class_name is blank" do
      params[:class_name] = ''
      expect(helper.class_of_page).to eq(Page)
    end
  end

  describe "determining the filter" do
    before :each do
      helper.send(:instance_variable_set, :@filter, nil)
    end

    it "should return nil when no filter is set" do
      expect(helper.filter).to be_nil
    end

    it "should return the filter object for the named filter" do
      params[:filter_name] = "Basic"
      expect(helper.filter).to eq(BasicFilter)
    end

    it "should return the filter object for a custom named filter" do
      params[:filter_name] = "Really Custom"
      expect(helper.filter).to eq(CustomFilter)
    end

    it "should return nil when the set filter is blank" do
      params[:filter_name] = ' '
      expect(helper.filter).to be_nil
    end
  end

  describe "determining the display name" do
    describe "when getting a filter reference" do
      before :each do
        helper.send(:instance_variable_set, :@filter, nil)
        params[:type] = 'filters'
      end

      it "should return the name of the set filter" do
        params[:filter_name] = "Basic"
        expect(helper._display_name).to eq("Basic")
      end

      it "should return <none> when no filter is set" do
        params[:filter_name] = nil
        expect(helper._display_name).to eq("<none>")
      end
    end

    describe "when getting a tag reference" do
      before :each do
        helper.send(:instance_variable_set, :@page_class, nil)
        params[:type] = 'tags'
      end

      it "should return the display name of the page class" do
        params[:class_name] = "FileNotFoundPage"
        expect(helper._display_name).to eq("File Not Found")
      end

      it "should return Page when <normal> is chosen" do
        params[:class_name] = nil
        expect(helper._display_name).to eq("Page")
      end
    end
  end

  describe "rendering the filter reference" do
    before :each do
      helper.send(:instance_variable_set, :@filter, nil)
      params[:type] = 'filters'
      params[:filter_name] = 'Basic'
    end

    it "should render a helpful message when the description is blank" do
      expect(BasicFilter).to receive(:description).and_return('')
      expect(helper.filter_reference).to eq("There is no documentation on this filter.")
    end

    it "should render the filter's description when available" do
      expect(BasicFilter).to receive(:description).at_least(:once).and_return('This is basic stuff.')
      expect(helper.filter_reference).to eq(BasicFilter.description)
    end

    it "should render a helpful message when no filter is selected" do
      params[:filter_name] = nil
      expect(helper.filter_reference).to eq("There is no filter on the current page part.")
    end
  end

  describe "rendering the tag reference" do
    before :each do
      helper.send(:instance_variable_set, :@page_class, nil)
      params[:type] = 'tags'
      params[:class_name] = ''
    end

    it "should render the tag reference partial for each tag description" do
      count = Page.tag_descriptions.size
      expect(helper).to receive(:render).exactly(count).times.and_return("desc")
      expect(helper.tag_reference).to eq("desc" * count)
    end
  end
end
