require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::Admin::NodeHelper do
  #dataset :users_and_pages

  before :each do
    @cookies = {}
    @errors = double("errors")
    allow(helper).to receive(:cookies).and_return(@cookies)
    allow(helper).to receive(:homepage).and_return(nil)
    @page = mock_model(Page, class_name: 'Page')
    allow(@page).to receive(:sheet?).and_return(false) # core extension alters the behavior
    allow(helper).to receive(:image).and_return('')
    allow(helper).to receive(:admin?).and_return(true)
    helper.instance_variable_set(:@page, @page)
  end

  it "should render a sitemap node" do
    expect(helper).to receive(:render).with(partial: "admin/pages/node", locals: {level: 0, simple: false, page: @page}).and_return(@current_node)
    helper.render_node(@page)
    helper.assigns[:current_node] == @page
  end

  it "should show all nodes when on the remove action" do
    assigns[:controller] = @controller
    expect(@controller).to receive(:action_name).and_return("remove")
    expect(helper.show_all?).to be true
  end

  it "should not show all nodes automatically when not in the remove action" do
    assigns[:controller] = @controller
    expect(@controller).to receive(:action_name).and_return("index")
    expect(helper.show_all?).to be false
  end

  it "should determine which rows to expand" do
    @cookies[:expanded_rows] = "1,2,3"
    expect(helper.expanded_rows).to eq([1,2,3])
  end

  it "should determine whether the current node should be expanded" do
    expect(helper).to receive(:show_all?).and_return(true)
    expect(helper.expanded).to be true
  end

  it "should determine the left padding for the current level" do
    expect(helper.padding_left(0)).to eq(9)
    expect(helper.padding_left(1)).to eq(32)
    expect(helper.padding_left(2)).to eq(55)
  end

  it "should determine the class of a parent node" do
    assigns[:current_node] = @page
    child = double("child")
    expect(@page).to receive(:children).and_return([child])
    expect(helper).to receive(:expanded).and_return(true)
    expect(helper.children_class).to eq(" children_visible")
  end

  it "should display an icon for the current node" do
    assigns[:current_node] = @page
    expect(@page).to receive(:virtual?).and_return(false)
    expect(helper).to receive(:image).with("page", class: "icon", alt: '', title: '')
    helper.icon
  end

  it "should display the virtual icon if the current node is virtual" do
    assigns[:current_node] = @page
    expect(@page).to receive(:virtual?).and_return(true)
    expect(helper).to receive(:image).with("virtual_page", class: "icon", alt: '', title: '')
    helper.icon
  end

  it "should render the title of the current node" do
    assigns[:current_node] = @page
    expect(@page).to receive(:title).and_return("Title")
    expect(helper.node_title).to eq(%{<span class="title">Title</span>})
  end

  it "should render the title of the current node with HTML entities escaped" do
    assigns[:current_node] = @page
    expect(@page).to receive(:title).and_return("Ham & Cheese")
    expect(helper.node_title).to eq(%{<span class="title">Ham &amp; Cheese</span>})
  end

  it "should render the page type if it's not Page" do
    assigns[:current_node] = @page
    @class = double("Class")
    expect(@page).to receive(:class).and_return(@class)
    expect(@class).to receive(:display_name).and_return("Special")
    expect(helper.page_type).to eq(%{<span class="info">(Special)</span>})
  end

  it "should not render the page type if it's Page" do
    assigns[:current_node] = @page
    expect(@page).to receive(:class).and_return(Page)
    expect(helper.page_type).to eq(%{})
  end

  it "should render the busy spinner" do
    assigns[:current_node] = @page
    expect(@page).to receive(:id).and_return(1)
    expect(helper).to receive(:image).with('spinner.gif',
            class: 'busy', id: "busy_1",
            alt: "",  title: "",
            style: 'display: none;')
    helper.spinner
  end


end