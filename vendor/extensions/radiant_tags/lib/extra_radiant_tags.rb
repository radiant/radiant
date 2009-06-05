module ExtraRadiantTags
  
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  tag "if_hide_page" do |tag|
    page = tag.locals.page
    if page.hide_in_menu?
      tag.expand
    end
  end
  
  tag "unless_hide_page" do |tag|
    page = tag.locals.page
    unless page.hide_in_menu?
      tag.expand
    end
  end
  
  desc %{
    When cycling through @<children:each/>@, the contents of this tag will be output
    only for the first child.
  }

  tag 'children:each:if_first' do |tag|
    children = tag.locals.children_filtered
    if children.first == tag.locals.child
      tag.expand
    end
  end

  desc %{
    When cycling through @<children:each/>@, the contents of this tag will be output
    only for the last child.
  }

  tag 'children:each:if_last' do |tag|
    children = tag.locals.children_filtered
    if children.last == tag.locals.child
      tag.expand
    end
  end

  desc %{
    When cycling through @<children:each/>@, the contents of this tag will be output
    only for the first and the last children.
  }

  tag 'children:each:if_first_or_last' do |tag|
    children = tag.locals.children_filtered
    if children.first == tag.locals.child or children.last == tag.locals.child
      tag.expand
    end
  end
  
  tag "children:each:if_index" do |tag|
    index = get_index(tag)
    i = tag.attr['divisible_by'].to_i
    if index % i == 0
      tag.expand
    end
  end

  protected 
    def get_index(tag)
      page = tag.locals.page
      children = tag.locals.page.parent.children
      children.index(page)
    end
  
end