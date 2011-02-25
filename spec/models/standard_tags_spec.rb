require File.dirname(__FILE__) + '/../spec_helper'

describe "Standard Tags" do
  dataset :users_and_pages, :file_not_found, :snippets

  it '<r:page> should allow access to the current page' do
    page(:home)
    page.should render('<r:page:title />').as('Home')
    page.should render(%{<r:find path="/radius"><r:title /> | <r:page:title /></r:find>}).as('Radius | Home')
  end

  [:breadcrumb, :slug, :title, :path].each do |attr|
    it "<r:#{attr}> should render the '#{attr}' attribute" do
      value = page.send(attr)
      page.should render("<r:#{attr} />").as(value.to_s)
    end
  end

  it "<r:path> with a nil relative URL root should scope to the relative root of /" do
    ActionController::Base.relative_url_root = nil
    page(:home).should render("<r:path />").as("/")
  end

  it '<r:path> with a relative URL root should scope to the relative root' do
    page(:home).should render("<r:path />").with_relative_root("/foo").as("/foo/")
  end

  it '<r:parent> should change the local context to the parent page' do
    page(:parent)
    page.should render('<r:parent><r:title /></r:parent>').as(pages(:home).title)
    page.should render('<r:parent><r:children:each by="title"><r:title /></r:children:each></r:parent>').as(page_eachable_children(pages(:home)).collect(&:title).join(""))
    page.should render('<r:children:each><r:parent:title /></r:children:each>').as(@page.title * page.children.count)
  end

  it '<r:if_parent> should render the contained block if the current page has a parent page' do
    page.should render('<r:if_parent>true</r:if_parent>').as('true')
    page(:home).should render('<r:if_parent>true</r:if_parent>').as('')
  end

  it '<r:unless_parent> should render the contained block unless the current page has a parent page' do
    page.should render('<r:unless_parent>true</r:unless_parent>').as('')
    page(:home).should render('<r:unless_parent>true</r:unless_parent>').as('true')
  end

  it '<r:if_children> should render the contained block if the current page has child pages' do
    page(:home).should render('<r:if_children>true</r:if_children>').as('true')
    page(:childless).should render('<r:if_children>true</r:if_children>').as('')
  end

  it '<r:unless_children> should render the contained block if the current page has no child pages' do
    page(:home).should render('<r:unless_children>true</r:unless_children>').as('')
    page(:childless).should render('<r:unless_children>true</r:unless_children>').as('true')
  end

  describe "<r:children:each>" do
    it "should iterate through the children of the current page" do
      page(:parent)
      page.should render('<r:children:each><r:title /> </r:children:each>').as('Child Child 2 Child 3 ')
      page.should render('<r:children:each><r:page><r:slug />/<r:child:slug /> </r:page></r:children:each>').as('parent/child parent/child-2 parent/child-3 ')
      page(:assorted).should render(page_children_each_tags).as('a b c d e f g h i j ')
    end

    it 'should not list draft pages' do
      page.should render('<r:children:each by="title"><r:slug /> </r:children:each>').as('a b c d e f g h i j ')
    end

    it 'should include draft pages with status="all"' do
      page.should render('<r:children:each status="all" by="slug"><r:slug /> </r:children:each>').as('a b c d draft e f g h i j ')
    end

    it "should include draft pages by default on the dev host" do
      page.should render('<r:children:each by="slug"><r:slug /> </r:children:each>').as('a b c d draft e f g h i j ').on('dev.site.com')
    end

    it 'should not list draft pages on dev.site.com when Radiant::Config["dev.host"] is set to something else' do
      Radiant::Config['dev.host'] = 'preview.site.com'
      page.should render('<r:children:each by="title"><r:slug /> </r:children:each>').as('a b c d e f g h i j ').on('dev.site.com')
    end

    describe 'with paginated="true"' do
      it 'should limit correctly the result set' do
        page.pagination_parameters = {:page => 1, :per_page => 10}
        page.should render('<r:children:each paginated="true" per_page="10"><r:slug /> </r:children:each>').as('a b c d e f g h i j ')
        page.should render('<r:children:each paginated="true" per_page="2"><r:slug /> </r:children:each>').not_matching(/a b c/)
      end
      it 'should display a pagination control block' do
        page.pagination_parameters = {:page => 1, :per_page => 1}
        page.should render('<r:children:each paginated="true"><r:slug /> </r:children:each>').matching(/div class="pagination"/)
      end
      it 'should link to the correct paginated page' do
        page(:another)
        page.pagination_parameters = {:page => 1, :per_page => 1}
        page.should render('<r:find path="/assorted"><r:children:each paginated="true"><r:slug /> </r:children:each></r:find>').matching(%r{href="/another})
      end
      it 'should pass through selected will_paginate parameters' do
        page(:assorted)
        page.pagination_parameters = {:page => 5, :per_page => 1}
        page.should render('<r:children:each paginated="true" separator="not that likely a choice"><r:slug /> </r:children:each>').matching(/not that likely a choice/)
        page.should render('<r:children:each paginated="true" previous_label="before"><r:slug /> </r:children:each>').matching(/before/)
        page.should render('<r:children:each paginated="true" next_label="after"><r:slug /> </r:children:each>').matching(/after/)
        page.should render('<r:children:each paginated="true" inner_window="1" outer_window="0"><r:slug /> </r:children:each>').not_matching(/\?p=2/)
      end
    end
    
    it 'should error with invalid "limit" attribute' do
      message = "`limit' attribute of `each' tag must be a positive number between 1 and 4 digits"
      page.should render(page_children_each_tags(%{limit="a"})).with_error(message)
      page.should render(page_children_each_tags(%{limit="-10"})).with_error(message)
      page.should render(page_children_each_tags(%{limit="50000"})).with_error(message)
    end

    it 'should error with invalid "offset" attribute' do
      message = "`offset' attribute of `each' tag must be a positive number between 1 and 4 digits"
      page.should render(page_children_each_tags(%{offset="a"})).with_error(message)
      page.should render(page_children_each_tags(%{offset="-10"})).with_error(message)
      page.should render(page_children_each_tags(%{offset="50000"})).with_error(message)
    end

    it 'should error with invalid "by" attribute' do
      message = "`by' attribute of `each' tag must be set to a valid field name"
      page.should render(page_children_each_tags(%{by="non-existant-field"})).with_error(message)
    end

    it 'should error with invalid "order" attribute' do
      message = %{`order' attribute of `each' tag must be set to either "asc" or "desc"}
      page.should render(page_children_each_tags(%{order="asdf"})).with_error(message)
    end

    it "should limit the number of children when given a 'limit' attribute" do
      page.should render(page_children_each_tags(%{limit="5"})).as('a b c d e ')
    end

    it "should limit and offset the children when given 'limit' and 'offset' attributes" do
      page.should render(page_children_each_tags(%{offset="3" limit="5"})).as('d e f g h ')
    end

    it "should change the sort order when given an 'order' attribute" do
      page.should render(page_children_each_tags(%{order="desc"})).as('j i h g f e d c b a ')
    end

    it "should sort by the 'by' attribute" do
      page.should render(page_children_each_tags(%{by="breadcrumb"})).as('f e d c b a j i h g ')
    end

    it "should sort by the 'by' attribute according to the 'order' attribute" do
      page.should render(page_children_each_tags(%{by="breadcrumb" order="desc"})).as('g h i j a b c d e f ')
    end

    describe 'with "status" attribute' do
      it "set to 'all' should list all children" do
        page.should render(page_children_each_tags(%{status="all"})).as("a b c d e f g h i j draft ")
      end

      it "set to 'draft' should list only children with 'draft' status" do
        page.should render(page_children_each_tags(%{status="draft"})).as('draft ')
      end

      it "set to 'published' should list only children with 'draft' status" do
        page.should render(page_children_each_tags(%{status="published"})).as('a b c d e f g h i j ')
      end

      it "set to an invalid status should render an error" do
        page.should render(page_children_each_tags(%{status="askdf"})).with_error("`status' attribute of `each' tag must be set to a valid status")
      end
    end
  end

  describe "<r:children:each:if_first>" do
    it "should render for the first child" do
      tags = '<r:children:each><r:if_first>FIRST:</r:if_first><r:slug /> </r:children:each>'
      expected = "FIRST:article article-2 article-3 article-4 "
      page(:news).should render(tags).as(expected)
    end
  end

  describe "<r:children:each:unless_first>" do
    it "should render for all but the first child" do
      tags = '<r:children:each><r:unless_first>NOT-FIRST:</r:unless_first><r:slug /> </r:children:each>'
      expected = "article NOT-FIRST:article-2 NOT-FIRST:article-3 NOT-FIRST:article-4 "
      page(:news).should render(tags).as(expected)
    end
  end

  describe "<r:children:each:if_last>" do
    it "should render for the last child" do
      tags = '<r:children:each><r:if_last>LAST:</r:if_last><r:slug /> </r:children:each>'
      expected = "article article-2 article-3 LAST:article-4 "
      page(:news).should render(tags).as(expected)
    end
  end

  describe "<r:children:each:unless_last>" do
    it "should render for all but the last child" do
      tags = '<r:children:each><r:unless_last>NOT-LAST:</r:unless_last><r:slug /> </r:children:each>'
      expected = "NOT-LAST:article NOT-LAST:article-2 NOT-LAST:article-3 article-4 "
      page(:news).should render(tags).as(expected)
    end
  end

  describe "<r:children:each:header>" do
    it "should render the header when it changes" do
      tags = '<r:children:each><r:header>[<r:date format="%b/%y" />] </r:header><r:slug /> </r:children:each>'
      expected = "[Dec/00] article [Feb/01] article-2 article-3 [Mar/01] article-4 "
      page(:news).should render(tags).as(expected)
    end

    it 'with "name" attribute should maintain a separate header' do
      tags = %{<r:children:each><r:header name="year">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:children:each>}
      expected = "[2000] (Dec) article [2001] (Feb) article-2 article-3 (Mar) article-4 "
      page(:news).should render(tags).as(expected)
    end

    it 'with "restart" attribute set to one name should restart that header' do
      tags = %{<r:children:each><r:header name="year" restart="month">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:children:each>}
      expected = "[2000] (Dec) article [2001] (Feb) article-2 article-3 (Mar) article-4 "
      page(:news).should render(tags).as(expected)
    end

    it 'with "restart" attribute set to two names should restart both headers' do
      tags = %{<r:children:each><r:header name="year" restart="month;day">[<r:date format='%Y' />] </r:header><r:header name="month" restart="day">(<r:date format="%b" />) </r:header><r:header name="day"><<r:date format='%d' />> </r:header><r:slug /> </r:children:each>}
      expected = "[2000] (Dec) <01> article [2001] (Feb) <09> article-2 <24> article-3 (Mar) <06> article-4 "
      page(:news).should render(tags).as(expected)
    end
  end

  describe "<r:children:count>" do
    it 'should render the number of children of the current page' do
      page(:parent).should render('<r:children:count />').as('3')
    end

    it "should accept the same scoping conditions as <r:children:each>" do
      page.should render('<r:children:count />').as('10')
      page.should render('<r:children:count status="all" />').as('11')
      page.should render('<r:children:count status="draft" />').as('1')
      page.should render('<r:children:count status="hidden" />').as('0')
    end
  end

  describe "<r:children:first>" do
    it 'should render its contents in the context of the first child page' do
      page(:parent).should render('<r:children:first:title />').as('Child')
    end

    it 'should accept the same scoping attributes as <r:children:each>' do
      page.should render(page_children_first_tags).as('a')
      page.should render(page_children_first_tags(%{limit="5"})).as('a')
      page.should render(page_children_first_tags(%{offset="3" limit="5"})).as('d')
      page.should render(page_children_first_tags(%{order="desc"})).as('j')
      page.should render(page_children_first_tags(%{by="breadcrumb"})).as('f')
      page.should render(page_children_first_tags(%{by="breadcrumb" order="desc"})).as('g')
    end

    it "should render nothing when no children exist" do
      page(:first).should render('<r:children:first:title />').as('')
    end
  end

  describe "<r:children:last>" do
    it 'should render its contents in the context of the last child page' do
      page(:parent).should render('<r:children:last:title />').as('Child 3')
    end

    it 'should accept the same scoping attributes as <r:children:each>' do
      page.should render(page_children_last_tags).as('j')
      page.should render(page_children_last_tags(%{limit="5"})).as('e')
      page.should render(page_children_last_tags(%{offset="3" limit="5"})).as('h')
      page.should render(page_children_last_tags(%{order="desc"})).as('a')
      page.should render(page_children_last_tags(%{by="breadcrumb"})).as('g')
      page.should render(page_children_last_tags(%{by="breadcrumb" order="desc"})).as('f')
    end

    it "should render nothing when no children exist" do
      page(:first).should render('<r:children:last:title />').as('')
    end
  end

  describe "<r:content>" do
    it "should render the 'body' part by default" do
      page.should render('<r:content />').as('Assorted body.')
    end

    it "with 'part' attribute should render the specified part" do
      page(:home).should render('<r:content part="extended" />').as("Just a test.")
    end

    it "should prevent simple recursion" do
      page(:recursive_parts).should render('<r:content />').with_error("Recursion error: already rendering the `body' part.")
    end

    it "should prevent deep recursion" do
      page(:recursive_parts).should render('<r:content part="one"/>').with_error("Recursion error: already rendering the `one' part.")
      page(:recursive_parts).should render('<r:content part="two"/>').with_error("Recursion error: already rendering the `two' part.")
    end

    it "should allow repetition" do
      page(:recursive_parts).should render('<r:content part="repeat"/>').as('xx')
    end

    it "should not prevent rendering a part more than once in sequence" do
      page(:home).should render('<r:content /><r:content />').as('Hello world!Hello world!')
    end

    describe "with inherit attribute" do
      it "missing or set to 'false' should render the current page's part" do
        page.should render('<r:content part="sidebar" />').as('')
        page.should render('<r:content part="sidebar" inherit="false" />').as('')
      end

      describe "set to 'true'" do
        it "should render an ancestor's part" do
          page.should render('<r:content part="sidebar" inherit="true" />').as('Assorted sidebar.')
        end
        it "should render nothing when no ancestor has the part" do
          page.should render('<r:content part="part_that_doesnt_exist" inherit="true" />').as('')
        end

        describe "and contextual attribute" do
          it "set to 'true' should render the part in the context of the current page" do
            page(:parent).should render('<r:content part="sidebar" inherit="true" contextual="true" />').as('Parent sidebar.')
            page(:child).should render('<r:content part="sidebar" inherit="true" contextual="true" />').as('Child sidebar.')
            page(:grandchild).should render('<r:content part="sidebar" inherit="true" contextual="true" />').as('Grandchild sidebar.')
          end

          it "set to 'false' should render the part in the context of its containing page" do
            page(:parent).should render('<r:content part="sidebar" inherit="true" contextual="false" />').as('Home sidebar.')
          end

          it "should maintain the global page" do
            page(:first)
            page.should render('<r:content part="titles" inherit="true" contextual="true"/>').as('First First')
            page.should render('<r:content part="titles" inherit="true" contextual="false"/>').as('Home First')
          end
        end
      end

      it "set to an erroneous value should render an error" do
        page.should render('<r:content part="sidebar" inherit="weird value" />').with_error(%{`inherit' attribute of `content' tag must be one of: true, false})
      end

      it "should render parts with respect to the current contextual page" do
        expected = "Child body. Child 2 body. Child 3 body. "
        page(:parent).should render('<r:children:each><r:content /> </r:children:each>').as(expected)
      end
    end
  end

  describe "<r:if_content>" do

    it "without 'part' attribute should render the contained block if the 'body' part exists" do
      page.should render('<r:if_content>true</r:if_content>').as('true')
    end

    it "should render the contained block if the specified part exists" do
      page.should render('<r:if_content part="body">true</r:if_content>').as('true')
    end

    it "should not render the contained block if the specified part does not exist" do
      page.should render('<r:if_content part="asdf">true</r:if_content>').as('')
    end

    describe "with more than one part given (separated by comma)" do

      it "should render the contained block only if all specified parts exist" do
        page(:home).should render('<r:if_content part="body, extended">true</r:if_content>').as('true')
      end

      it "should not render the contained block if at least one of the specified parts does not exist" do
        page(:home).should render('<r:if_content part="body, madeup">true</r:if_content>').as('')
      end

      describe "with inherit attribute set to 'true'" do
        it 'should render the contained block if the current or ancestor pages have the specified parts' do
          page(:guests).should render('<r:if_content part="favors, extended" inherit="true">true</r:if_content>').as('true')
        end

        it 'should not render the contained block if the current or ancestor pages do not have all of the specified parts' do
          page(:guests).should render('<r:if_content part="favors, madeup" inherit="true">true</r:if_content>').as('')
        end
        
        describe "with find attribute set to 'any'" do
          it 'should render the contained block if the current or ancestor pages have any of the specified parts' do
            page(:guests).should render('<r:if_content part="favors, madeup" inherit="true" find="any">true</r:if_content>').as('true')
          end
          
          it 'should still render the contained block if first of the specified parts has not been found' do
            page(:guests).should render('<r:if_content part="madeup, favors" inherit="true" find="any">true</r:if_content>').as('true')
          end
        end
      end
      
      describe "with inherit attribute set to 'false'" do
        it 'should render the contained block if the current page has the specified parts' do
          page(:guests).should render('<r:if_content part="favors, games" inherit="false">true</r:if_content>').as('')
        end

        it 'should not render the contained block if the current or ancestor pages do not have all of the specified parts' do
          page(:guests).should render('<r:if_content part="favors, madeup" inherit="false">true</r:if_content>').as('')
        end
      end
      describe "with the 'find' attribute set to 'any'" do
        it "should render the contained block if any of the specified parts exist" do
          page.should render('<r:if_content part="body, asdf" find="any">true</r:if_content>').as('true')
        end
      end
      describe "with the 'find' attribute set to 'all'" do
        it "should render the contained block if all of the specified parts exist" do
          page(:home).should render('<r:if_content part="body, sidebar" find="all">true</r:if_content>').as('true')
        end

        it "should not render the contained block if all of the specified parts do not exist" do
          page.should render('<r:if_content part="asdf, madeup" find="all">true</r:if_content>').as('')
        end
      end
    end
  end

  describe "<r:unless_content>" do
    describe "with inherit attribute set to 'true'" do
      it 'should not render the contained block if the current or ancestor pages have the specified parts' do
        page(:guests).should render('<r:unless_content part="favors, extended" inherit="true">true</r:unless_content>').as('')
      end

      it 'should render the contained block if the current or ancestor pages do not have the specified parts' do
        page(:guests).should render('<r:unless_content part="madeup, imaginary" inherit="true">true</r:unless_content>').as('true')
      end

      it "should not render the contained block if the specified part does not exist but does exist on an ancestor" do
        page.should render('<r:unless_content part="sidebar" inherit="true">false</r:unless_content>').as('')
      end
      
      describe "with find attribute set to 'any'" do
        it 'should not render the contained block if the current or ancestor pages have any of the specified parts' do
          page(:guests).should render('<r:unless_content part="favors, madeup" inherit="true" find="any">true</r:unless_content>').as('')
        end
        
        it 'should still not render the contained block if first of the specified parts has not been found' do
          page(:guests).should render('<r:unless_content part="madeup, favors" inherit="true" find="any">true</r:unless_content>').as('')
        end
      end
    end

    it "without 'part' attribute should not render the contained block if the 'body' part exists" do
      page.should render('<r:unless_content>false</r:unless_content>').as('')
    end

    it "should not render the contained block if the specified part exists" do
      page.should render('<r:unless_content part="body">false</r:unless_content>').as('')
    end

    it "should render the contained block if the specified part does not exist" do
      page.should render('<r:unless_content part="asdf">false</r:unless_content>').as('false')
    end

    it "should render the contained block if the specified part does not exist but does exist on an ancestor" do
      page.should render('<r:unless_content part="sidebar">false</r:unless_content>').as('false')
    end

    describe "with more than one part given (separated by comma)" do

      it "should not render the contained block if all of the specified parts exist" do
        page(:home).should render('<r:unless_content part="body, extended">true</r:unless_content>').as('')
      end

      it "should render the contained block if at least one of the specified parts exists" do
        page(:home).should render('<r:unless_content part="body, madeup">true</r:unless_content>').as('true')
      end

      describe "with the 'inherit' attribute set to 'true'" do
        it "should render the contained block if the current or ancestor pages have none of the specified parts" do
          page.should render('<r:unless_content part="imaginary, madeup" inherit="true">true</r:unless_content>').as('true')
        end

        it "should not render the contained block if all of the specified parts are present on the current or ancestor pages" do
          page(:party).should render('<r:unless_content part="favors, extended" inherit="true">true</r:unless_content>').as('')
        end
      end

      describe "with the 'find' attribute set to 'all'" do
        it "should not render the contained block if all of the specified parts exist" do
          page(:home).should render('<r:unless_content part="body, sidebar" find="all">true</r:unless_content>').as('')
        end

        it "should render the contained block unless all of the specified parts exist" do
          page.should render('<r:unless_content part="body, madeup" find="all">true</r:unless_content>').as('true')
        end
      end

      describe "with the 'find' attribute set to 'any'" do
        it "should not render the contained block if any of the specified parts exist" do
          page.should render('<r:unless_content part="body, madeup" find="any">true</r:unless_content>').as('')
        end
      end
    end
  end

  describe "<r:aggregate>" do
    it "should raise an error when given no 'paths' attribute" do
      pages(:home).should render('<r:aggregate></r:aggregate>').with_error("`aggregate' tag must contain a `paths' or `urls' attribute.")
    end
    it "should expand its contents with a given 'paths' attribute formatted as '/path1; /path2;'" do
      pages(:home).should render('<r:aggregate paths="/parent/child; /first;">true</r:aggregate>').as('true')
    end
  end
  
  describe "<r:aggregate:children>" do
    it "should expand its contents" do
      pages(:home).should render('<r:aggregate paths="/parent/child; /first;"><r:children>true</r:children></r:aggregate>').as('true') 
    end
  end
  
  describe "<r:aggregate:children:count>" do
    it "should display the number of aggregated children" do
      pages(:home).should render('<r:aggregate paths="/news; /assorted"><r:children:count /></r:aggregate>').as('14')
    end
  end
  
  describe "<r:aggregate:children:each>" do
    it "should loop through each child from the given paths" do
      pages(:home).should render('<r:aggregate paths="/parent; /news"><r:children:each by="title"><r:title/> </r:children:each></r:aggregate>').as('Article Article 2 Article 3 Article 4 Child Child 2 Child 3 ')
    end
    it "should sort the children by the given 'by' attribute" do
      pages(:home).should render('<r:aggregate paths="/assorted; /news"><r:children:each by="slug"><r:slug /> </r:children:each></r:aggregate>').as('a article article-2 article-3 article-4 b c d e f g h i j ')
    end
    it "should order the children by the given 'order' attribute when used with 'by'" do
      pages(:home).should render('<r:aggregate paths="/assorted; /news"><r:children:each by="slug" order="desc"><r:slug /> </r:children:each></r:aggregate>').as('j i h g f e d c b article-4 article-3 article-2 article a ')
    end
    it "should limit the number of results with the given 'limit' attribute" do
      pages(:home).should render('<r:aggregate paths="/assorted; /news"><r:children:each by="slug" order="desc" limit="3"><r:slug /> </r:children:each></r:aggregate>').as('j i h ')
    end
  end
  
  describe "<r:aggregate:each>" do
    it "should loop through each of the given aggregate paths" do
      pages(:home).should render('<r:aggregate paths="/parent/child; /first; /assorted;"><r:each><r:title /> </r:each></r:aggregate>').as('Child First Assorted ')
    end
    it "should display it's contents in the scope of the individually aggregated page" do
      pages(:home).should render('<r:aggregate paths="/parent; /news; /assorted;"><r:each><r:children:each><r:title /> </r:children:each></r:each></r:aggregate>').as('Child Child 2 Child 3 Article Article 2 Article 3 Article 4 a b c d e f g h i j ')
    end
  end

  describe "<r:author>" do
    it "should render the author of the current page" do
      page.should render('<r:author />').as('Admin')
    end

    it "should render nothing when the page has no author" do
      page(:no_user).should render('<r:author />').as('')
    end
  end

  describe "<r:gravatar>" do
    it "should render the Gravatar URL of author of the current page" do
      page.should render('<r:gravatar />').as('http://www.gravatar.com/avatar.php?gravatar_id=e64c7d89f26bd1972efa854d13d7dd61&rating=G&size=32&default=http://testhost.tld/images/admin/avatar_32x32.png')
    end

    it "should render the Gravatar URL of the name user" do
      page.should render('<r:gravatar name="Admin" />').as('http://www.gravatar.com/avatar.php?gravatar_id=e64c7d89f26bd1972efa854d13d7dd61&rating=G&size=32&default=http://testhost.tld/images/admin/avatar_32x32.png')
    end

    it "should render the default avatar when the user has not set an email address" do
      page.should render('<r:gravatar name="Designer" />').as('http://testhost.tld/images/admin/avatar_32x32.png')
    end

    it "should render the specified size" do
      page.should render('<r:gravatar name="Designer" size="96px" />').as('http://testhost.tld/images/admin/avatar_96x96.png')
    end

    it "should render the specified rating" do
      page.should render('<r:gravatar rating="X" />').as('http://www.gravatar.com/avatar.php?gravatar_id=e64c7d89f26bd1972efa854d13d7dd61&rating=X&size=32&default=http://testhost.tld/images/admin/avatar_32x32.png')
    end
  end

  describe "<r:date>" do
    before :each do
      page(:dated)
    end

    it "should render the published date of the page" do
      page.should render('<r:date />').as('Wednesday, January 11, 2006')
    end

    it "should format the published date according to the 'format' attribute" do
      page.should render('<r:date format="%d %b %Y" />').as('11 Jan 2006')
    end

    it "should format the published date according to localized format" do
      page.should render('<r:date format="short" />').as(I18n.l(page.published_at, :format => :short))
    end

    describe "with 'for' attribute" do
      it "set to 'now' should render the current date in the current Time.zone" do
        page.should render('<r:date for="now" />').as(Time.zone.now.strftime("%A, %B %d, %Y"))
      end

      it "set to 'created_at' should render the creation date" do
        page.should render('<r:date for="created_at" />').as('Tuesday, January 10, 2006')
      end

      it "set to 'updated_at' should render the update date" do
        page.should render('<r:date for="updated_at" />').as('Thursday, January 12, 2006')
      end

      it "set to 'published_at' should render the publish date" do
        page.should render('<r:date for="published_at" />').as('Wednesday, January 11, 2006')
      end

      it "set to an invalid attribute should render an error" do
        page.should render('<r:date for="blah" />').with_error("Invalid value for 'for' attribute.")
      end
    end

    it "should use the currently set timezone" do
      Time.zone = "Tokyo"
      format = "%H:%m"
      expected = page.published_at.in_time_zone(ActiveSupport::TimeZone['Tokyo']).strftime(format)
      page.should render(%Q(<r:date format="#{format}" />) ).as(expected)
    end
  end

  describe "<r:link>" do
    it "should render a link to the current page" do
      page.should render('<r:link />').as('<a href="/assorted/">Assorted</a>')
    end

    it "should render its contents as the text of the link" do
      page.should render('<r:link>Test</r:link>').as('<a href="/assorted/">Test</a>')
    end

    it "should pass HTML attributes to the <a> tag" do
      expected = '<a href="/assorted/" class="test" id="assorted">Assorted</a>'
      page.should render('<r:link class="test" id="assorted" />').as(expected)
    end

    it "should add the anchor attribute to the link as a URL anchor" do
      page.should render('<r:link anchor="test">Test</r:link>').as('<a href="/assorted/#test">Test</a>')
    end

    it "should render a link for the current contextual page" do
      expected = %{<a href="/parent/child/">Child</a> <a href="/parent/child-2/">Child 2</a> <a href="/parent/child-3/">Child 3</a> }
      page(:parent).should render('<r:children:each><r:link /> </r:children:each>' ).as(expected)
    end

    it "should scope the link within the relative URL root" do
      page(:assorted).should render('<r:link />').with_relative_root('/foo').as('<a href="/foo/assorted/">Assorted</a>')
    end
  end

  describe "<r:snippet>" do
    it "should render the contents of the specified snippet" do
      page.should render('<r:snippet name="first" />').as('test')
    end

    it "should render an error when the snippet does not exist" do
      page.should render('<r:snippet name="non-existant" />').with_error("snippet 'non-existant' not found")
    end

    it "should render an error when not given a 'name' attribute" do
      page.should render('<r:snippet />').with_error("`snippet' tag must contain a `name' attribute.")
    end

    it "should filter the snippet with its assigned filter" do
      page.should render('<r:page><r:snippet name="markdown" /></r:page>').matching(%r{<p><strong>markdown</strong></p>})
    end

    it "should maintain the global page inside the snippet" do
      page(:parent).should render('<r:snippet name="global_page_cascade" />').as("#{@page.title} " * @page.children.count)
    end

    it "should maintain the global page when the snippet renders recursively" do
      page(:child).should render('<r:snippet name="recursive" />').as("Great GrandchildGrandchildChild")
    end

    it "should render the specified snippet when called as an empty double-tag" do
      page.should render('<r:snippet name="first"></r:snippet>').as('test')
    end

    it "should capture contents of a double tag, substituting for <r:yield/> in snippet" do
      page.should render('<r:snippet name="yielding">inner</r:snippet>').
        as('Before...inner...and after')
    end

    it "should do nothing with contents of double tag when snippet doesn't yield" do
      page.should render('<r:snippet name="first">content disappears!</r:snippet>').
        as('test')
    end

    it "should render nested yielding snippets" do
      page.should render('<r:snippet name="div_wrap"><r:snippet name="yielding">Hello, World!</r:snippet></r:snippet>').
      as('<div>Before...Hello, World!...and after</div>')
    end

    it "should render double-tag snippets called from within a snippet" do
      page.should render('<r:snippet name="nested_yields">the content</r:snippet>').
        as('<snippet name="div_wrap">above the content below</snippet>')
    end

    it "should render contents each time yield is called" do
      page.should render('<r:snippet name="yielding_often">French</r:snippet>').
        as('French is Frencher than French')
    end
  end

  it "should do nothing when called from page body" do
    page.should render('<r:yield/>').as("")
  end

  it '<r:random> should render a randomly selected contained <r:option>' do
    page.should render("<r:random> <r:option>1</r:option> <r:option>2</r:option> <r:option>3</r:option> </r:random>").matching(/^(1|2|3)$/)
  end

  it '<r:random> should render a randomly selected, dynamically set <r:option>' do
    page(:parent).should render("<r:random:children:each:option:title />").matching(/^(Child|Child\ 2|Child\ 3)$/)
  end

  it '<r:comment> should render nothing it contains' do
    page.should render('just a <r:comment>small </r:comment>test').as('just a test')
  end
  
  describe '<r:hide>' do
    it "should not display it's contents" do
      page.should render('just a <r:hide>small </r:hide>test').as('just a test')
    end
  end

  describe "<r:navigation>" do
    it "should render the nested <r:normal> tag by default" do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted/ | Parent: /parent/">
                 <r:normal><r:title /></r:normal>
               </r:navigation>}
      expected = %{Home Assorted Parent}
      page.should render(tags).as(expected)
    end

    it "should render the nested <r:selected> tag for paths that match the current page" do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted/ | Parent: /parent/ | Radius: /radius/">
                 <r:normal><r:title /></r:normal>
                 <r:selected><strong><r:title/></strong></r:selected>
               </r:navigation>}
      expected = %{<strong>Home</strong> Assorted <strong>Parent</strong> Radius}
      page(:parent).should render(tags).as(expected)
    end

    it "should render the nested <r:here> tag for paths that exactly match the current page" do
      tags = %{<r:navigation paths="Home: Boy: / | Assorted: /assorted/ | Parent: /parent/">
                 <r:normal><a href="<r:path />"><r:title /></a></r:normal>
                 <r:here><strong><r:title /></strong></r:here>
                 <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
                 <r:between> | </r:between>
               </r:navigation>}
      expected = %{<strong><a href="/">Home: Boy</a></strong> | <strong>Assorted</strong> | <a href="/parent/">Parent</a>}
      page.should render(tags).as(expected)
    end

    it "should render the nested <r:between> tag between each link" do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted/ | Parent: /parent/">
                 <r:normal><r:title /></r:normal>
                 <r:between> :: </r:between>
               </r:navigation>}
      expected = %{Home :: Assorted :: Parent}
      page.should render(tags).as(expected)
    end

    it 'without paths should render nothing' do
      page.should render(%{<r:navigation><r:normal /></r:navigation>}).as('')
    end

    it 'without a nested <r:normal> tag should render an error' do
      page.should render(%{<r:navigation paths="something:here"></r:navigation>}).with_error( "`navigation' tag must include a `normal' tag")
    end

    it 'with paths without trailing slashes should match corresponding pages' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><r:title /></r:normal>
                 <r:here><strong><r:title /></strong></r:here>
               </r:navigation>}
      expected = %{Home <strong>Assorted</strong> Parent Radius}
      page.should render(tags).as(expected)
    end

    it 'should prune empty blocks' do
      tags = %{<r:navigation paths="Home: Boy: / | Archives: /archive/ | Radius: /radius/ | Docs: /documentation/">
                 <r:normal><a href="<r:path />"><r:title /></a></r:normal>
                 <r:here></r:here>
                 <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
                 <r:between> | </r:between>
               </r:navigation>}
      expected = %{<strong><a href="/">Home: Boy</a></strong> | <a href="/archive/">Archives</a> | <a href="/documentation/">Docs</a>}
      page(:radius).should render(tags).as(expected)
    end

    it 'should render text under <r:if_first> and <r:if_last> only on the first and last item, respectively' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><r:if_first>(</r:if_first><a href="<r:path />"><r:title /></a><r:if_last>)</r:if_last></r:normal>
                 <r:here><r:if_first>(</r:if_first><r:title /><r:if_last>)</r:if_last></r:here>
                 <r:selected><r:if_first>(</r:if_first><strong><a href="<r:path />"><r:title /></a></strong><r:if_last>)</r:if_last></r:selected>
               </r:navigation>}
      expected = %{(<strong><a href=\"/\">Home</a></strong> <a href=\"/assorted\">Assorted</a> <a href=\"/parent\">Parent</a> Radius)}
      page(:radius).should render(tags).as(expected)
    end

    it 'should render text under <r:unless_first> on every item but the first' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><r:unless_first>&gt; </r:unless_first><a href="<r:path />"><r:title /></a></r:normal>
                 <r:here><r:unless_first>&gt; </r:unless_first><r:title /></r:here>
                 <r:selected><r:unless_first>&gt; </r:unless_first><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
               </r:navigation>}
      expected = %{<strong><a href=\"/\">Home</a></strong> &gt; <a href=\"/assorted\">Assorted</a> &gt; <a href=\"/parent\">Parent</a> &gt; Radius}
      page(:radius).should render(tags).as(expected)
    end

    it 'should render text under <r:unless_last> on every item but the last' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><a href="<r:path />"><r:title /></a><r:unless_last> &gt;</r:unless_last></r:normal>
                 <r:here><r:title /><r:unless_last> &gt;</r:unless_last></r:here>
                 <r:selected><strong><a href="<r:path />"><r:title /></a></strong><r:unless_last> &gt;</r:unless_last></r:selected>
               </r:navigation>}
      expected = %{<strong><a href=\"/\">Home</a></strong> &gt; <a href=\"/assorted\">Assorted</a> &gt; <a href=\"/parent\">Parent</a> &gt; Radius}
      page(:radius).should render(tags).as(expected)
    end
  end

  describe "<r:find>" do
    it "should change the local page to the page specified in the 'path' attribute" do
      page.should render(%{<r:find path="/parent/child/"><r:title /></r:find>}).as('Child')
    end

    it "should render an error without a 'path' or 'url' attribute" do
      page.should render(%{<r:find />}).with_error("`find' tag must contain a `path' or `url' attribute.")
    end

    it "should render nothing when the 'path' attribute does not point to a page" do
      page.should render(%{<r:find path="/asdfsdf/"><r:title /></r:find>}).as('')
    end

    it "should render nothing when the 'path' attribute does not point to a page and a custom 404 page exists" do
      page.should render(%{<r:find path="/gallery/asdfsdf/"><r:title /></r:find>}).as('')
    end

    it "should scope contained tags to the found page" do
      page.should render(%{<r:find path="/parent/"><r:children:each><r:slug /> </r:children:each></r:find>}).as('child child-2 child-3 ')
    end

    it "should accept a path relative to the current page" do
      page(:great_grandchild).should render(%{<r:find path="../../../child-2"><r:title/></r:find>}).as("Child 2")
    end
  end

  it '<r:escape_html> should escape HTML-related characters into entities' do
    page.should render('<r:escape_html><strong>a bold move</strong></r:escape_html>').as('&lt;strong&gt;a bold move&lt;/strong&gt;')
  end

  it '<r:rfc1123_date> should render an RFC1123-compatible date' do
    page(:dated).should render('<r:rfc1123_date />').as('Wed, 11 Jan 2006 00:00:00 GMT')
  end

  describe "<r:breadcrumbs>" do
    it "should render a series of breadcrumb links separated by &gt;" do
      expected = %{<a href="/">Home</a> &gt; <a href="/parent/">Parent</a> &gt; <a href="/parent/child/">Child</a> &gt; <a href="/parent/child/grandchild/">Grandchild</a> &gt; Great Grandchild}
      page(:great_grandchild).should render('<r:breadcrumbs />').as(expected)
    end

    it "with a 'separator' attribute should use the separator instead of &gt;" do
      expected = %{<a href="/">Home</a> :: Parent}
      page(:parent).should render('<r:breadcrumbs separator=" :: " />').as(expected)
    end

    it "with a 'nolinks' attribute set to 'true' should not render links" do
      expected = %{Home &gt; Parent}
      page(:parent).should render('<r:breadcrumbs nolinks="true" />').as(expected)
    end

    it "with a relative URL root should scope links to the relative root" do
      expected = '<a href="/foo/">Home</a> &gt; Assorted'
      page(:assorted).should render('<r:breadcrumbs />').with_relative_root('/foo').as(expected)
    end
  end

  describe "<r:if_path>" do
    describe "with 'matches' attribute" do
      it "should render the contained block if the page URL matches" do
        page.should render('<r:if_path matches="a.sorted/$">true</r:if_path>').as('true')
      end

      it "should not render the contained block if the page URL does not match" do
        page.should render('<r:if_path matches="fancypants">true</r:if_path>').as('')
      end

      it "set to a malformatted regexp should render an error" do
        page.should render('<r:if_path matches="as(sorted/$">true</r:if_path>').with_error("Malformed regular expression in `matches' argument of `if_path' tag: unmatched (: /as(sorted\\/$/")
      end

      it "without 'ignore_case' attribute should ignore case by default" do
        page.should render('<r:if_path matches="asSorted/$">true</r:if_path>').as('true')
      end

      describe "with 'ignore_case' attribute" do
        it "set to 'true' should use a case-insensitive match" do
          page.should render('<r:if_path matches="asSorted/$" ignore_case="true">true</r:if_path>').as('true')
        end

        it "set to 'false' should use a case-sensitive match" do
          page.should render('<r:if_path matches="asSorted/$" ignore_case="false">true</r:if_path>').as('')
        end
      end
    end

    it "with no attributes should render an error" do
      page.should render('<r:if_path>test</r:if_path>').with_error("`if_path' tag must contain a `matches' attribute.")
    end
  end

  describe "<r:unless_path>" do
    describe "with 'matches' attribute" do
      it "should not render the contained block if the page URL matches" do
        page.should render('<r:unless_path matches="a.sorted/$">true</r:unless_path>').as('')
      end

      it "should render the contained block if the page URL does not match" do
        page.should render('<r:unless_path matches="fancypants">true</r:unless_path>').as('true')
      end

      it "set to a malformatted regexp should render an error" do
        page.should render('<r:unless_path matches="as(sorted/$">true</r:unless_path>').with_error("Malformed regular expression in `matches' argument of `unless_path' tag: unmatched (: /as(sorted\\/$/")
      end

      it "without 'ignore_case' attribute should ignore case by default" do
        page.should render('<r:unless_path matches="asSorted/$">true</r:unless_path>').as('')
      end

      describe "with 'ignore_case' attribute" do
        it "set to 'true' should use a case-insensitive match" do
          page.should render('<r:unless_path matches="asSorted/$">true</r:unless_path>').as('')
        end

        it "set to 'false' should use a case-sensitive match" do
          page.should render('<r:unless_path matches="asSorted/$" ignore_case="false">true</r:unless_path>').as('true')
        end
      end
    end

    it "with no attributes should render an error" do
      page.should render('<r:unless_path>test</r:unless_path>').with_error("`unless_path' tag must contain a `matches' attribute.")
    end
  end

  describe "<r:cycle>" do
    subject { page }
    it "should render passed values in succession" do
      page.should render('<r:cycle values="first, second" /> <r:cycle values="first, second" />').as('first second')
    end

    it "should return to the beginning of the cycle when reaching the end" do
      page.should render('<r:cycle values="first, second" /> <r:cycle values="first, second" /> <r:cycle values="first, second" />').as('first second first')
    end

    it "should start at a given start value" do
      page.should render('<r:cycle values="first, second, third" start="second" /> <r:cycle values="first, second, third" start="second" /> <r:cycle values="first, second, third" start="second" />').as('second third first')
    end

    it "should use a default cycle name of 'cycle'" do
      page.should render('<r:cycle values="first, second" /> <r:cycle values="first, second" name="cycle" />').as('first second')
    end

    it "should maintain separate cycle counters" do
      page.should render('<r:cycle values="first, second" /> <r:cycle values="one, two" name="numbers" /> <r:cycle values="first, second" /> <r:cycle values="one, two" name="numbers" />').as('first one second two')
    end

    it "should reset the counter" do
      page.should render('<r:cycle values="first, second" /> <r:cycle values="first, second" reset="true"/>').as('first first')
    end
    
    it { should render('<r:cycle /> <r:cycle />').as('0 1') }
    it { should render('<r:cycle start="3" /> <r:cycle start="3" /> <r:cycle start="3" />').as('3 4 5') }
    it { should render('<r:cycle start="3" /> <r:cycle name="other" /> <r:cycle start="3" />').as('3 0 4') }
    it { should render('<r:cycle start="3" /> <r:cycle name="other" start="23" /> <r:cycle />').as('3 23 4') }
    it { should render('<r:cycle start="3" /> <r:cycle name="other" start="23" /> <r:cycle reset="true" />').as('3 23 0') }
  end

  describe "<r:if_dev>" do
    it "should render the contained block when on the dev site" do
      page.should render('-<r:if_dev>dev</r:if_dev>-').as('-dev-').on('dev.site.com')
    end

    it "should not render the contained block when not on the dev site" do
      page.should render('-<r:if_dev>dev</r:if_dev>-').as('--')
    end
    
    it "should not render the contained block when no request is present" do
      page(:devtags).render_part('if_dev').should_not have_text('dev')
    end

    describe "on an included page" do
      it "should render the contained block when on the dev site" do
        page.should render('-<r:find path="/devtags/"><r:content part="if_dev" /></r:find>-').as('-dev-').on('dev.site.com')
      end

      it "should not render the contained block when not on the dev site" do
        page.should render('-<r:find path="/devtags/"><r:content part="if_dev" /></r:find>-').as('--')
      end
    end
  end

  describe "<r:unless_dev>" do
    it "should not render the contained block when not on the dev site" do
      page.should render('-<r:unless_dev>not dev</r:unless_dev>-').as('--').on('dev.site.com')
    end

    it "should render the contained block when not on the dev site" do
      page.should render('-<r:unless_dev>not dev</r:unless_dev>-').as('-not dev-')
    end

    it "should render the contained block when no request is present" do
      page(:devtags).render_part('unless_dev').should have_text('not dev')
    end

    describe "on an included page" do
      it "should not render the contained block when not on the dev site" do
        page.should render('-<r:find path="/devtags/"><r:content part="unless_dev" /></r:find>-').as('--').on('dev.site.com')
      end

      it "should render the contained block when not on the dev site" do
        page.should render('-<r:find path="/devtags/"><r:content part="unless_dev" /></r:find>-').as('-not dev-')
      end
    end
  end

  describe "<r:status>" do
    it "should render the status of the current page" do
      status_tag = "<r:status/>"
      page(:a).should render(status_tag).as("Published")
      page(:hidden).should render(status_tag).as("Hidden")
      page(:draft).should render(status_tag).as("Draft")
    end

    describe "with the downcase attribute set to 'true'" do
      it "should render the lowercased status of the current page" do
        status_tag_lc = "<r:status downcase='true'/>"
        page(:a).should render(status_tag_lc).as("published")
        page(:hidden).should render(status_tag_lc).as("hidden")
        page(:draft).should render(status_tag_lc).as("draft")
      end
    end
  end

  describe "<r:if_ancestor_or_self>" do
    it "should render the tag's content when the current page is an ancestor of tag.locals.page" do
      page(:radius).should render(%{<r:find path="/"><r:if_ancestor_or_self>true</r:if_ancestor_or_self></r:find>}).as('true')
    end

    it "should not render the tag's content when current page is not an ancestor of tag.locals.page" do
      page(:parent).should render(%{<r:find path="/radius"><r:if_ancestor_or_self>true</r:if_ancestor_or_self></r:find>}).as('')
    end
  end

  describe "<r:unless_ancestor_or_self>" do
    it "should render the tag's content when the current page is not an ancestor of tag.locals.page" do
      page(:parent).should render(%{<r:find path="/radius"><r:unless_ancestor_or_self>true</r:unless_ancestor_or_self></r:find>}).as('true')
    end

    it "should not render the tag's content when current page is an ancestor of tag.locals.page" do
      page(:radius).should render(%{<r:find path="/"><r:unless_ancestor_or_self>true</r:unless_ancestor_or_self></r:find>}).as('')
    end
  end

  describe "<r:if_self>" do
    it "should render the tag's content when the current page is the same as the local contextual page" do
      page(:home).should render(%{<r:find path="/"><r:if_self>true</r:if_self></r:find>}).as('true')
    end

    it "should not render the tag's content when the current page is not the same as the local contextual page" do
      page(:radius).should render(%{<r:find path="/"><r:if_self>true</r:if_self></r:find>}).as('')
    end
  end

  describe "<r:unless_self>" do
    it "should render the tag's content when the current page is not the same as the local contextual page" do
      page(:radius).should render(%{<r:find path="/"><r:unless_self>true</r:unless_self></r:find>}).as('true')
    end

    it "should not render the tag's content when the current page is the same as the local contextual page" do
      page(:home).should render(%{<r:find path="/"><r:unless_self>true</r:unless_self></r:find>}).as('')
    end
  end

  describe "Field tags" do
    subject{
      p = Page.new(:slug => "/", :parent_id => nil, :title => 'Home')
      field = PageField.new(:name => 'Field', :content => "Sweet harmonious biscuits")
      blank_field = PageField.new(:name => 'blank', :content => "")
      p.fields = [field, blank_field]
      p
    }

    describe '<r:field>' do
      it { should render('<r:field name="field" />').as('Sweet harmonious biscuits') }
      it { should render('<r:field name="bogus" />').as('') }
    end

    describe "<r:if_field>" do
      it { should render('<r:if_field name="field">Ok</r:if_field>').as('Ok') }
      it { should render('<r:if_field name="bogus">Ok</r:if_field>').as('') }
      it { should render('<r:if_field name="field" equals="sweet harmonious biscuits">Ok</r:if_field>').as('Ok') }
      it { should render('<r:if_field name="bogus" equals="sweet harmonious biscuits">Ok</r:if_field>').as('') }
      it { should render('<r:if_field name="field" equals="sweet harmonious biscuits" ignore_case="false">Ok</r:if_field>').as('') }
      it { should render('<r:if_field name="field" matches="^sweet\s">Ok</r:if_field>').as('Ok') }
      it { should render('<r:if_field name="field" matches="^sweet\s" ignore_case="false">Ok</r:if_field>').as('') }
      it { should render('<r:if_field name="blank" matches="[^\s]">Not here</r:if_field>').as('') }
      it { should render('<r:if_field name="bogus" matches="something">Not here</r:if_field>').as('') }
    end

    describe "<r:unless_field>" do
      it { should render('<r:unless_field name="field">Ok</r:unless_field>').as('') }
      it { should render('<r:unless_field name="bogus">Ok</r:unless_field>').as('Ok') }
      it { should render('<r:unless_field name="field" equals="sweet harmonious biscuits">Ok</r:unless_field>').as('') }
      it { should render('<r:unless_field name="bogus" equals="sweet harmonious biscuits">Ok</r:unless_field>').as('Ok') }
      it { should render('<r:unless_field name="field" equals="sweet harmonious biscuits" ignore_case="false">Ok</r:unless_field>').as('Ok') }
      it { should render('<r:unless_field name="field" matches="^sweet\s">Ok</r:unless_field>').as('') }
      it { should render('<r:unless_field name="field" matches="^sweet\s" ignore_case="false">Ok</r:unless_field>').as('Ok') }
      it { should render('<r:unless_field name="blank" matches="[^\s]">Not here</r:unless_field>').as('Not here') }
      it { should render('<r:unless_field name="bogus" matches="something">Not here</r:unless_field>').as('Not here') }
    end
    
  end

  private

    def page(symbol = nil)
      if symbol.nil?
        @page ||= pages(:assorted)
      else
        @page = pages(symbol)
      end
    end

    def page_children_each_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:children:each#{attr}><r:slug /> </r:children:each>"
    end

    def page_children_first_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:children:first#{attr}><r:slug /></r:children:first>"
    end

    def page_children_last_tags(attr = nil)
      attr = ' ' + attr unless attr.nil?
      "<r:children:last#{attr}><r:slug /></r:children:last>"
    end

    def page_eachable_children(page)
      page.children.select(&:published?).reject(&:virtual)
    end
end
