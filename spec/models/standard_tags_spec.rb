require File.dirname(__FILE__) + '/../spec_helper'

describe "Standard Tags" do
  test_helper :page

  let!(:home){ FactoryGirl.create(:home) do |page|
    page.created_by = FactoryGirl.create(:admin)
    page.parts.create(name: "body", content: "Hello world!")
    page.parts.create(name: "sidebar", content: "<r:title /> sidebar.")
    page.parts.create(name: "extended", content: "Just a test.")
    page.parts.create(name: "titles", content: "<r:title /> <r:page:title />")
  end}
  let(:page){ FactoryGirl.create(:published_page, parent: home, title: 'Page') }
  let(:radius){ FactoryGirl.create(:published_page, parent: home, title: 'Radius')}
  
  let(:parent){ FactoryGirl.create(:page_with_body_page_part, parent: home, title: 'Parent') }
  let(:child){ FactoryGirl.create(:page_with_body_page_part, parent: parent, title: 'Child') }
  let(:grandchild){ FactoryGirl.create(:page_with_body_and_sidebar_parts, parent: child, title: 'Grandchild') }
  let(:great_grandchild){ FactoryGirl.create(:published_page, parent: grandchild, title: 'Great Grandchild') }
  let(:child_2){ FactoryGirl.create(:page_with_body_page_part, parent: parent, title: 'Child 2') }
  let(:child_3){ FactoryGirl.create(:page_with_body_page_part, parent: parent, title: 'Child 3') }
  
  let(:news){ FactoryGirl.create(:published_page, parent: home, title: 'News') }
  dates = ['2000-12-01 08:41:07', '2001-02-09 08:42:04', '2001-02-24 12:02:43', '2001-03-06 03:32:31']
  dates.each do |date|
    title = "Article#{(' ' + (dates.index(date) + 1).to_s) unless date == dates.first}"
    let(title.downcase.gsub(' ', '_').to_sym){
      FactoryGirl.create(:published_page, published_at: DateTime.parse(date), title: title, parent: news)
    }
  end
  let(:draft){ FactoryGirl.create(:page, title: "Draft", parent: news, status: Status[:draft]) }
  
  let(:assorted){ FactoryGirl.create(:published_page, parent: home, title: 'Assorted') }
  breadcrumbs = %w(f e d c b a j i h g)
  %w(a b c d e f g h i j).each_with_index do |name, i|
    let(name.to_sym){
      FactoryGirl.create(:published_page, breadcrumb: breadcrumbs[i], published_at: Time.now - (10 - i).minutes, title: name, parent: assorted)
    }
  end
  let(:assorted_draft){ FactoryGirl.create(:published_page, parent: home, title: "Assorted Draft", status_id: Status[:draft].id, slug: "draft") }
  let(:assorted_draft){ FactoryGirl.create(:published_page, parent: home, title: "Assorted Virtual", class_name: "VirtualPage", virtual: true, slug: "virtual") }
    
  date = Time.utc(2006, 1, 11)
  let(:dated){ FactoryGirl.create(:published_page, parent: home, title: 'Dated', published_at: date, created_at: (date - 1.day), updated_at: (date + 1.day))}
  let(:scheduled){ FactoryGirl.create(:page, parent: home, title: 'Scheduled', published_at: (Time.now + 1.day), status_id: Status[:scheduled].id)}
  
  let(:devtags){ FactoryGirl.create(:published_page, parent: home, title: 'Devtags') do |page|
      page.parts.create(name: 'if_dev', content: "<r:if_dev>dev</r:if_dev>")
      page.parts.create(name: 'unless_dev', content: "<r:unless_dev>not dev</r:unless_dev>")
    end }
    
  let(:recursive_parts){ FactoryGirl.create(:published_page, parent: home, title: 'Recursive parts') do |page|
    page.parts.create(name: "body", content: "<r:content />")
    page.parts.create(name: "one", content: '<r:content part="two" />')
    page.parts.create(name: "two", content: '<r:content part="one" />')
    page.parts.create(name: "repeat", content: '<r:content part="beat"/><r:content part="beat"/>')
    page.parts.create(name: "beat", content: 'x')
  end}
#   let(:file_not_found){ FactoryGirl.create(:file_not_found_page, parent_id: home.id, slug: '404', published_at: Time.now, status_id: Status[:published].id)}

  it '<r:page> should allow access to the current page' do
    radius
    expect(home).to render('<r:page:title />').as('Home')
    expect(home).to render(%{<r:find path="/radius"><r:title /> | <r:page:title /></r:find>}).as('Radius | Home')
  end

  [:breadcrumb, :slug, :title, :path].each do |attr|
    it "<r:#{attr}> should render the '#{attr}' attribute" do
      value = page.send(attr)
      expect(page).to render("<r:#{attr} />").as(value.to_s)
    end
  end
  
  [:title, :dev_host, :host].each do |attr|
    it "<r:site:#{attr}> should render the '#{attr}' attribute from Radiant.detail" do
      value = Radiant.detail[attr]
      expect(page).to render("<r:site:#{attr} />").as(value)
    end
  end

  it "<r:path> with a nil relative URL root should scope to the relative root of /" do
    ActionController::Base.relative_url_root = nil
    expect(home).to render("<r:path />").as("/")
  end

  it '<r:path> with a relative URL root should scope to the relative root' do
    expect(home).to render("<r:path />").with_relative_root("/foo").as("/foo/")
  end
  # 
  # it "<r:url> should act like r:path but issue a deprecation warning" do
  #   ActionController::Base.relative_url_root = nil
  #   ActiveSupport::Deprecation.should_receive(:warn).and_return(true)
  #   home.should render("<r:url />").as("/")
  # end
  
  it '<r:parent> should change the local context to the parent page' do
    expect(page).to render('<r:parent><r:title /></r:parent>').as(home.title)
    expect(page).to render('<r:parent><r:children:each by="title"><r:title /></r:children:each></r:parent>').as(page_eachable_children(home).collect(&:title).join(""))
    child; child_2; child_3
    expect(parent).to render('<r:children:each><r:parent:title /></r:children:each>').as(parent.title * parent.children.count)
  end

  it '<r:if_parent> should render the contained block if the current page has a parent page' do
    expect(page).to render('<r:if_parent>true</r:if_parent>').as('true')
    expect(home).to render('<r:if_parent>true</r:if_parent>').as('')
  end

  it '<r:unless_parent> should render the contained block unless the current page has a parent page' do
    expect(page).to render('<r:unless_parent>true</r:unless_parent>').as('')
    expect(home).to render('<r:unless_parent>true</r:unless_parent>').as('true')
  end

  it '<r:if_children> should render the contained block if the current page has child pages' do
    expect(radius).to render('<r:if_children>true</r:if_children>').as('')
    expect(home).to render('<r:if_children>true</r:if_children>').as('true')
  end

  it '<r:unless_children> should render the contained block if the current page has no child pages' do
    expect(radius).to render('<r:unless_children>true</r:unless_children>').as('true')
    expect(home).to render('<r:unless_children>true</r:unless_children>').as('')
  end

  describe "<r:children:each>" do
    it "should iterate through the children of the current page" do
      child; child_2; child_3
      expect(parent).to render('<r:children:each><r:title /> </r:children:each>').as('Child Child 2 Child 3 ')
      expect(parent).to render('<r:children:each><r:page><r:slug />/<r:child:slug /> </r:page></r:children:each>').as('parent/child parent/child-2 parent/child-3 ')
    end

    describe 'with paginated="true"' do
      it 'should limit correctly the result set' do
        a; b; c; d; e; f; g; h; i; j
        assorted.pagination_parameters = {page: 1, per_page: 10}
        expect(assorted).to render('<r:children:each paginated="true" per_page="10"><r:slug /> </r:children:each>').as('a b c d e f g h i j ')
        expect(assorted).to render('<r:children:each paginated="true" per_page="2"><r:slug /> </r:children:each>').not_matching(/a b c/)
      end
      it 'should display a pagination control block' do
        a; b; c; d; e; f; g; h; i; j
        assorted.pagination_parameters = {page: 1, per_page: 1}
        expect(assorted).to render('<r:children:each paginated="true"><r:slug /> </r:children:each>').matching(/div class="pagination"/)
      end
      it 'should link to the correct paginated page' do
        assorted; a; b; c; d; e; f; g; h; i; j
        page.pagination_parameters = {page: 1, per_page: 1}
        expect(page).to render('<r:find path="/assorted"><r:children:each paginated="true"><r:slug /> </r:children:each></r:find>').matching(%r{href="/page})
      end
      it 'should pass through selected will_paginate parameters' do
        assorted; a; b; c; d; e; f; g; h; i; j
        assorted.pagination_parameters = {page: 5, per_page: 1}
        expect(assorted).to render('<r:children:each paginated="true" separator="not that likely a choice"><r:slug /> </r:children:each>').matching(/not that likely a choice/)
        expect(assorted).to render('<r:children:each paginated="true" previous_label="before"><r:slug /> </r:children:each>').matching(/before/)
        expect(assorted).to render('<r:children:each paginated="true" next_label="after"><r:slug /> </r:children:each>').matching(/after/)
        expect(assorted).to render('<r:children:each paginated="true" inner_window="1" outer_window="0"><r:slug /> </r:children:each>').not_matching(/\?p=2/)
      end
    end

    it 'should error with invalid "limit" attribute' do
      message = "`limit' attribute must be a positive number"
      expect(page).to render(page_children_each_tags(%{limit="a"})).with_error(message)
      expect(page).to render(page_children_each_tags(%{limit="-10"})).with_error(message)
    end

    it 'should error with invalid "offset" attribute' do
      message = "`offset' attribute must be a positive number"
      expect(page).to render(page_children_each_tags(%{offset="a"})).with_error(message)
      expect(page).to render(page_children_each_tags(%{offset="-10"})).with_error(message)
    end

    it 'should error with invalid "by" attribute' do
      message = "`by' attribute of `each' tag must be set to a valid field name"
      expect(page).to render(page_children_each_tags(%{by="non-existant-field"})).with_error(message)
    end

    it 'should error with invalid "order" attribute' do
      message = %{`order' attribute of `each' tag must be set to either "asc" or "desc"}
      expect(page).to render(page_children_each_tags(%{order="asdf"})).with_error(message)
    end

    it "should limit the number of children when given a 'limit' attribute" do
      a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_each_tags(%{limit="5"})).as('a b c d e ')
    end

    it "should limit and offset the children when given 'limit' and 'offset' attributes" do
      a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_each_tags(%{offset="3" limit="5"})).as('d e f g h ')
    end

    it "should change the sort order when given an 'order' attribute" do
      a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_each_tags(%{order="desc"})).as('j i h g f e d c b a ')
    end

    it "should sort by the 'by' attribute" do
      a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_each_tags(%{by="breadcrumb"})).as('f e d c b a j i h g ')
    end

    it "should sort by the 'by' attribute according to the 'order' attribute" do
      a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_each_tags(%{by="breadcrumb" order="desc"})).as('g h i j a b c d e f ')
    end

    describe 'with "status" attribute' do
      it "set to 'all' should list all children" do
        article; article_2; article_3; article_4; draft
        expect(news).to render(page_children_each_tags(%{status="all"})).as("draft article article-2 article-3 article-4 ")
      end

      it "set to 'draft' should list only children with 'draft' status" do
        article; article_2; article_3; article_4; draft
        expect(news).to render(page_children_each_tags(%{status="draft"})).as('draft ')
      end

      it "set to 'published' should list only children with 'published' status" do
        article; article_2; article_3; article_4; draft
        expect(news).to render(page_children_each_tags(%{status="published"})).as('article article-2 article-3 article-4 ')
      end

      it "set to an invalid status should render an error" do
        article; article_2; article_3; article_4; draft
        expect(news).to render(page_children_each_tags(%{status="askdf"})).with_error("`status' attribute of `each' tag must be set to a valid status")
      end
    end
    
    xit 'should not list draft pages on dev.site.com when Radiant.detail["dev.host"] is set to something else' do
      Radiant.detail['dev.host'] = 'preview.site.com'
      article; article_2; article_3; article_4; draft
      expect(page).to render('<r:children:each by="title"><r:slug /> </r:children:each>').as('article article-2 article-3 article-4 ').on('dev.site.com')
      # TODO: Find out why this is cached into next examples (if_dev tests)
    end    
  end

  describe "<r:children:each:if_first>" do
    it "should render for the first child" do
      article; article_2; article_3; article_4
      tags = '<r:children:each><r:if_first>FIRST:</r:if_first><r:slug /> </r:children:each>'
      expected = "FIRST:article article-2 article-3 article-4 "
      expect(news).to render(tags).as(expected)
    end
  end

  describe "<r:children:each:unless_first>" do
    it "should render for all but the first child" do
      article; article_2; article_3; article_4
      tags = '<r:children:each><r:unless_first>NOT-FIRST:</r:unless_first><r:slug /> </r:children:each>'
      expected = "article NOT-FIRST:article-2 NOT-FIRST:article-3 NOT-FIRST:article-4 "
      expect(news).to render(tags).as(expected)
    end
  end

  describe "<r:children:each:if_last>" do
    it "should render for the last child" do
      article; article_2; article_3; article_4
      tags = '<r:children:each><r:if_last>LAST:</r:if_last><r:slug /> </r:children:each>'
      expected = "article article-2 article-3 LAST:article-4 "
      expect(news).to render(tags).as(expected)
    end
  end

  describe "<r:children:each:unless_last>" do
    it "should render for all but the last child" do
      article; article_2; article_3; article_4
      tags = '<r:children:each><r:unless_last>NOT-LAST:</r:unless_last><r:slug /> </r:children:each>'
      expected = "NOT-LAST:article NOT-LAST:article-2 NOT-LAST:article-3 article-4 "
      expect(news).to render(tags).as(expected)
    end
  end

  describe "<r:children:each:header>" do
    it "should render the header when it changes" do
      article; article_2; article_3; article_4
      tags = '<r:children:each><r:header>[<r:date format="%b/%y" />] </r:header><r:slug /> </r:children:each>'
      expected = "[Dec/00] article [Feb/01] article-2 article-3 [Mar/01] article-4 "
      expect(news).to render(tags).as(expected)
    end

    it 'with "name" attribute should maintain a separate header' do
      article; article_2; article_3; article_4
      tags = %{<r:children:each><r:header name="year">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:children:each>}
      expected = "[2000] (Dec) article [2001] (Feb) article-2 article-3 (Mar) article-4 "
      expect(news).to render(tags).as(expected)
    end

    it 'with "restart" attribute set to one name should restart that header' do
      article; article_2; article_3; article_4
      tags = %{<r:children:each><r:header name="year" restart="month">[<r:date format='%Y' />] </r:header><r:header name="month">(<r:date format="%b" />) </r:header><r:slug /> </r:children:each>}
      expected = "[2000] (Dec) article [2001] (Feb) article-2 article-3 (Mar) article-4 "
      expect(news).to render(tags).as(expected)
    end

    it 'with "restart" attribute set to two names should restart both headers' do
      article; article_2; article_3; article_4
      tags = %{<r:children:each><r:header name="year" restart="month;day">[<r:date format='%Y' />] </r:header><r:header name="month" restart="day">(<r:date format="%b" />) </r:header><r:header name="day"><<r:date format='%d' />> </r:header><r:slug /> </r:children:each>}
      expected = "[2000] (Dec) <01> article [2001] (Feb) <09> article-2 <24> article-3 (Mar) <06> article-4 "
      expect(news).to render(tags).as(expected)
    end
  end

  describe "<r:children:count>" do
    it 'should render the number of children of the current page' do
      child; child_2; child_3
      expect(parent).to render('<r:children:count />').as('3')
    end

    it "should accept the same scoping conditions as <r:children:each>" do
      article; article_2; article_3; article_4; draft
      expect(news).to render('<r:children:count />').as('4')
      expect(news).to render('<r:children:count status="all" />').as('5')
      expect(news).to render('<r:children:count status="draft" />').as('1')
      expect(news).to render('<r:children:count status="hidden" />').as('0')
    end
  end

  describe "<r:children:first>" do
    it 'should render its contents in the context of the first child page' do
      child; child_2; child_3
      expect(parent).to render('<r:children:first:title />').as('Child')
    end

    it 'should accept the same scoping attributes as <r:children:each>' do
      assorted; a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_first_tags).as('a')
      expect(assorted).to render(page_children_first_tags(%{limit="5"})).as('a')
      expect(assorted).to render(page_children_first_tags(%{offset="3" limit="5"})).as('d')
      expect(assorted).to render(page_children_first_tags(%{order="desc"})).as('j')
      expect(assorted).to render(page_children_first_tags(%{by="breadcrumb"})).as('f')
      expect(assorted).to render(page_children_first_tags(%{by="breadcrumb" order="desc"})).as('g')
    end

    it "should render nothing when no children exist" do
      expect(radius).to render('<r:children:first:title />').as('')
    end
  end

  describe "<r:children:last>" do
    it 'should render its contents in the context of the last child page' do
      article; article_2; article_3; article_4
      expect(news).to render('<r:children:last:title />').as('Article 4')
    end

    it 'should accept the same scoping attributes as <r:children:each>' do
      assorted; a; b; c; d; e; f; g; h; i; j
      expect(assorted).to render(page_children_last_tags).as('j')
      expect(assorted).to render(page_children_last_tags(%{limit="5"})).as('e')
      expect(assorted).to render(page_children_last_tags(%{offset="3" limit="5"})).as('h')
      expect(assorted).to render(page_children_last_tags(%{order="desc"})).as('a')
      expect(assorted).to render(page_children_last_tags(%{by="breadcrumb"})).as('g')
      expect(assorted).to render(page_children_last_tags(%{by="breadcrumb" order="desc"})).as('f')
    end

    it "should render nothing when no children exist" do
      expect(radius).to render('<r:children:last:title />').as('')
    end
  end

  describe "<r:content>" do
    it "should render the 'body' part by default" do
      expect(home).to render('<r:content />').as('Hello world!')
    end

    it "with 'part' attribute should render the specified part" do
      expect(home).to render('<r:content part="extended" />').as("Just a test.")
    end

    it "should prevent simple recursion" do
      expect(recursive_parts).to render('<r:content />').with_error("Recursion error: already rendering the `body' part.")
    end

    it "should prevent deep recursion" do
      expect(recursive_parts).to render('<r:content part="one"/>').with_error("Recursion error: already rendering the `one' part.")
      expect(recursive_parts).to render('<r:content part="two"/>').with_error("Recursion error: already rendering the `two' part.")
    end

    it "should allow repetition" do
      expect(recursive_parts).to render('<r:content part="repeat"/>').as('xx')
    end

    it "should not prevent rendering a part more than once in sequence" do
      expect(home).to render('<r:content /><r:content />').as('Hello world!Hello world!')
    end

    describe "with inherit attribute" do
      it "missing or set to 'false' should render the current page's part" do
        expect(page).to render('<r:content part="sidebar" />').as('')
        expect(page).to render('<r:content part="sidebar" inherit="false" />').as('')
      end

      describe "set to 'true'" do
        it "should render an ancestor's part" do
          expect(assorted).to render('<r:content part="sidebar" inherit="true" />').as('Assorted sidebar.')
        end
        it "should render nothing when no ancestor has the part" do
          expect(page).to render('<r:content part="part_that_doesnt_exist" inherit="true" />').as('')
        end

        describe "and contextual attribute" do
          it "set to 'true' should render the part in the context of the current page" do
            expect(parent).to render('<r:content part="sidebar" inherit="true" contextual="true" />').as('Parent sidebar.')
            expect(child).to render('<r:content part="sidebar" inherit="true" contextual="true" />').as('Child sidebar.')
            expect(grandchild).to render('<r:content part="sidebar" inherit="true" contextual="true" />').as('Grandchild sidebar.')
          end

          it "set to 'false' should render the part in the context of its containing page" do
            expect(parent).to render('<r:content part="sidebar" inherit="true" contextual="false" />').as('Home sidebar.')
          end

          it "should maintain the global page" do
            expect(page).to render('<r:content part="titles" inherit="true" contextual="true"/>').as('Page Page')
            expect(page).to render('<r:content part="titles" inherit="true" contextual="false"/>').as('Home Page')
          end
        end
      end

      it "set to an erroneous value should render an error" do
        expect(page).to render('<r:content part="sidebar" inherit="weird value" />').with_error(%{`inherit' attribute of `content' tag must be one of: true, false})
      end

      it "should render parts with respect to the current contextual page" do
        child; child_2; child_3
        expected = "Child body. Child 2 body. Child 3 body. "
        expect(parent).to render('<r:children:each><r:content /> </r:children:each>').as(expected)
      end
    end
  end

  describe "<r:if_content>" do
    it "without 'part' attribute should render the contained block if the 'body' part exists" do
      expect(home).to render('<r:if_content>true</r:if_content>').as('true')
    end

    it "should render the contained block if the specified part exists" do
      expect(home).to render('<r:if_content part="body">true</r:if_content>').as('true')
    end

    it "should not render the contained block if the specified part does not exist" do
      expect(home).to render('<r:if_content part="asdf">true</r:if_content>').as('')
    end

    describe "with more than one part given (separated by comma)" do

      it "should render the contained block only if all specified parts exist" do
        expect(home).to render('<r:if_content part="body, extended">true</r:if_content>').as('true')
      end

      it "should not render the contained block if at least one of the specified parts does not exist" do
        expect(home).to render('<r:if_content part="body, madeup">true</r:if_content>').as('')
      end

      describe "with inherit attribute set to 'true'" do
        it 'should render the contained block if the current or ancestor pages have the specified parts' do
          expect(child).to render('<r:if_content part="body, sidebar" inherit="true">true</r:if_content>').as('true')
        end

        it 'should not render the contained block if the current or ancestor pages do not have all of the specified parts' do
          expect(child).to render('<r:if_content part="body, madeup" inherit="true">true</r:if_content>').as('')
        end

        describe "with find attribute set to 'any'" do
          it 'should render the contained block if the current or ancestor pages have any of the specified parts' do
            expect(child).to render('<r:if_content part="body, madeup" inherit="true" find="any">true</r:if_content>').as('true')
          end

          it 'should still render the contained block if first of the specified parts has not been found' do
            expect(child).to render('<r:if_content part="madeup, body" inherit="true" find="any">true</r:if_content>').as('true')
          end
        end
      end

      describe "with inherit attribute set to 'false'" do
        it 'should render the contained block if the current page has the specified parts' do
          expect(grandchild).to render('<r:if_content part="body, sidebar" inherit="false">true</r:if_content>').as('true')
        end

        it 'should not render the contained block if the current or ancestor pages do not have all of the specified parts' do
          expect(child).to render('<r:if_content part="body, sidebar" inherit="false">true</r:if_content>').as('')
        end
      end
      describe "with the 'find' attribute set to 'any'" do
        it "should render the contained block if any of the specified parts exist" do
          expect(child).to render('<r:if_content part="body, asdf" find="any">true</r:if_content>').as('true')
        end
      end
      describe "with the 'find' attribute set to 'all'" do
        it "should render the contained block if all of the specified parts exist" do
          expect(grandchild).to render('<r:if_content part="body, sidebar" find="all">true</r:if_content>').as('true')
        end

        it "should not render the contained block if any of the specified parts do not exist" do
          expect(child).to render('<r:if_content part="body, madeup" find="all">true</r:if_content>').as('')
        end
      end
    end
  end

  describe "<r:unless_content>" do
    describe "with inherit attribute set to 'true'" do
      it 'should not render the contained block if the current or ancestor pages have the specified parts' do
        expect(child).to render('<r:unless_content part="body, sidebar" inherit="true">true</r:unless_content>').as('')
      end

      it 'should render the contained block if the current or ancestor pages do not have the specified parts' do
        expect(child).to render('<r:unless_content part="madeup, imaginary" inherit="true">true</r:unless_content>').as('true')
      end

      it "should not render the contained block if the specified part does not exist but does exist on an ancestor" do
        expect(child).to render('<r:unless_content part="sidebar" inherit="true">false</r:unless_content>').as('')
      end

      describe "with find attribute set to 'any'" do
        it 'should not render the contained block if the current or ancestor pages have any of the specified parts' do
          expect(child).to render('<r:unless_content part="sidebar, madeup" inherit="true" find="any">true</r:unless_content>').as('')
        end

        it 'should still not render the contained block if first of the specified parts has not been found' do
          expect(child).to render('<r:unless_content part="madeup, sidebar" inherit="true" find="any">true</r:unless_content>').as('')
        end
      end
    end

    it "without 'part' attribute should not render the contained block if the 'body' part exists" do
      expect(home).to render('<r:unless_content>false</r:unless_content>').as('')
    end

    it "should not render the contained block if the specified part exists" do
      expect(home).to render('<r:unless_content part="body">false</r:unless_content>').as('')
    end

    it "should render the contained block if the specified part does not exist" do
      expect(home).to render('<r:unless_content part="asdf">false</r:unless_content>').as('false')
    end

    it "should render the contained block if the specified part does not exist but does exist on an ancestor" do
      expect(child).to render('<r:unless_content part="sidebar">false</r:unless_content>').as('false')
    end

    describe "with more than one part given (separated by comma)" do

      it "should not render the contained block if all of the specified parts exist" do
        expect(home).to render('<r:unless_content part="body, extended">true</r:unless_content>').as('')
      end

      it "should render the contained block if at least one of the specified parts exists" do
        expect(home).to render('<r:unless_content part="body, madeup">true</r:unless_content>').as('true')
      end

      describe "with the 'inherit' attribute set to 'true'" do
        it "should render the contained block if the current or ancestor pages have none of the specified parts" do
          expect(page).to render('<r:unless_content part="imaginary, madeup" inherit="true">true</r:unless_content>').as('true')
        end

        it "should not render the contained block if all of the specified parts are present on the current or ancestor pages" do
          expect(great_grandchild).to render('<r:unless_content part="body, sidebar" inherit="true">true</r:unless_content>').as('')
        end
      end

      describe "with the 'find' attribute set to 'all'" do
        it "should not render the contained block if all of the specified parts exist" do
          expect(home).to render('<r:unless_content part="body, sidebar" find="all">true</r:unless_content>').as('')
        end

        it "should render the contained block unless all of the specified parts exist" do
          expect(home).to render('<r:unless_content part="body, madeup" find="all">true</r:unless_content>').as('true')
        end
      end

      describe "with the 'find' attribute set to 'any'" do
        it "should not render the contained block if any of the specified parts exist" do
          expect(home).to render('<r:unless_content part="body, madeup" find="any">true</r:unless_content>').as('')
        end
      end
    end
  end

  describe "<r:aggregate>" do
    it "should raise an error when given no 'paths' attribute" do
      expect(home).to render('<r:aggregate></r:aggregate>').with_error("`aggregate' tag must contain a `paths' or `urls' attribute.")
    end
    it "should expand its contents with a given 'paths' attribute formatted as '/path1; /path2;'" do
      parent;child;page
      expect(home).to render('<r:aggregate paths="/parent/child; /page;">true</r:aggregate>').as('true')
    end
  end

  describe "<r:aggregate:children>" do
    it "should expand its contents" do
      parent;child;page
      expect(home).to render('<r:aggregate paths="/parent/child; /page;"><r:children>true</r:children></r:aggregate>').as('true')
    end
  end

  describe "<r:aggregate:children:count>" do
    it "should display the number of aggregated children" do
      news; article; article_2; article_3; article_4
      assorted; a; b; c; d; e; f; g; h; i; j
      expect(home).to render('<r:aggregate paths="/news; /assorted"><r:children:count /></r:aggregate>').as('14')
    end
  end

  describe "<r:aggregate:children:each>" do
    it "should loop through each child from the given paths" do
      news; article; article_2; article_3; article_4; parent; child; child_2; child_3
      expect(home).to render('<r:aggregate paths="/parent; /news"><r:children:each by="title"><r:title/> </r:children:each></r:aggregate>').as('Article Article 2 Article 3 Article 4 Child Child 2 Child 3 ')
    end
    it "should sort the children by the given 'by' attribute" do
      news; article; article_2; article_3; article_4
      assorted; a; b; c; d; e; f; g; h; i; j
      expect(home).to render('<r:aggregate paths="/assorted; /news"><r:children:each by="slug"><r:slug /> </r:children:each></r:aggregate>').as('a article article-2 article-3 article-4 b c d e f g h i j ')
    end
    it "should order the children by the given 'order' attribute when used with 'by'" do
      news; article; article_2; article_3; article_4
      assorted; a; b; c; d; e; f; g; h; i; j
      expect(home).to render('<r:aggregate paths="/assorted; /news"><r:children:each by="slug" order="desc"><r:slug /> </r:children:each></r:aggregate>').as('j i h g f e d c b article-4 article-3 article-2 article a ')
    end
    it "should limit the number of results with the given 'limit' attribute" do
      news; article; article_2; article_3; article_4
      assorted; a; b; c; d; e; f; g; h; i; j
      expect(home).to render('<r:aggregate paths="/assorted; /news"><r:children:each by="slug" order="desc" limit="3"><r:slug /> </r:children:each></r:aggregate>').as('j i h ')
    end

    describe 'with paginated="true"' do
      it 'should limit correctly the result set' do
        news; article; article_2; article_3; article_4
        assorted; a; b; c; d; e; f; g; h; i; j
        page.pagination_parameters = {page: 1, per_page: 10}
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true" per_page="10"><r:slug /> </r:children:each></r:aggregate>').matching(/article article-2 article-3 article-4 a b c d e f /)
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true" per_page="2"><r:slug /> </r:children:each></r:aggregate>').not_matching(/article article-2 article-3/)
      end
      it 'should display a pagination control block' do
        news; article; article_2; article_3; article_4
        assorted; a; b; c; d; e; f; g; h; i; j
        page.pagination_parameters = {page: 1, per_page: 1}
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true"><r:slug /> </r:children:each></r:aggregate>').matching(/div class="pagination"/)
      end
      it 'should link to the correct paginated page' do
        assorted; a; b; c; d; e; f; g; h; i; j
        page.pagination_parameters = {page: 1, per_page: 1}
        expect(page).to render('<r:find path="/assorted"><r:children:each paginated="true"><r:slug /> </r:children:each></r:find>').matching(%r{href="/page})
      end
      it 'should pass through selected will_paginate parameters' do
        assorted; a; b; c; d; e; f; g; h; i; j
        news
        page.pagination_parameters = {page: 5, per_page: 1}
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true" separator="not that likely a choice"><r:slug /> </r:children:each></r:aggregate>').matching(/not that likely a choice/)
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true" previous_label="before"><r:slug /> </r:children:each></r:aggregate>').matching(/before/)
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true" next_label="after"><r:slug /> </r:children:each></r:aggregate>').matching(/after/)
        expect(page).to render('<r:aggregate paths="/assorted; /news"><r:children:each paginated="true" inner_window="1" outer_window="0"><r:slug /> </r:children:each></r:aggregate>').not_matching(/\?p=2/)
      end
    end
  end

  describe "<r:aggregate:each>" do
    it "should loop through each of the given aggregate paths" do
      parent; child; news; page
      expect(home).to render('<r:aggregate paths="/parent/child; /news; /page;"><r:each><r:title /> </r:each></r:aggregate>').as('Child News Page ')
    end
    it "should display it's contents in the scope of the individually aggregated page" do
      parent; child; child_2; child_3; article; article_2; article_3; article_4; news;
      expect(home).to render('<r:aggregate paths="/parent; /news;"><r:each><r:children:each><r:title /> </r:children:each></r:each></r:aggregate>').as('Child Child 2 Child 3 Article Article 2 Article 3 Article 4 ')
    end
  end

  describe "<r:author>" do
    it "should render the author of the current page" do
      expect(home).to render('<r:author />').as('Admin')
    end

    it "should render nothing when the page has no author" do
      expect(page).to render('<r:author />').as('')
    end
  end

  describe "<r:gravatar>" do
    it "should render the Gravatar URL of author of the current page" do
      expect(home).to render('<r:gravatar />').as('//gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?rating=G&size=32')
    end

    it "should render the Gravatar URL of the name user" do
      expect(page).to render('<r:gravatar name="Admin" />').as('//gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?rating=G&size=32')
    end

    it "should render the default avatar when the user has not set an email address" do
      expect(page).to render('<r:gravatar name="Designer" />').as('/assets/admin/avatar_32x32.png')
    end

    it "should render the specified size" do
      expect(page).to render('<r:gravatar name="Designer" size="96px" />').as('/assets/admin/avatar_96x96.png')
    end

    it "should render the specified rating" do
      expect(home).to render('<r:gravatar rating="X" />').as('//gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?rating=X&size=32')
    end
  end

  describe "<r:date>" do
    it "should render the published date of the page" do
      expect(dated).to render('<r:date />').as('Wednesday, January 11, 2006')
    end

    it "should format the published date according to the 'format' attribute" do
      expect(dated).to render('<r:date format="%d %b %Y" />').as('11 Jan 2006')
    end

    it "should format the published date according to localized format" do
      expect(dated).to render('<r:date format="short" />').as(I18n.l(dated.published_at, format: :short))
    end

    describe "with 'for' attribute" do
      it "set to 'now' should render the current date in the current Time.zone" do
        expect(dated).to render('<r:date for="now" />').as(Time.zone.now.strftime("%A, %B %d, %Y"))
      end

      it "set to 'created_at' should render the creation date" do
        expect(dated).to render('<r:date for="created_at" />').as('Tuesday, January 10, 2006')
      end

      it "set to 'updated_at' should render the update date" do
        expect(dated).to render('<r:date for="updated_at" />').as('Thursday, January 12, 2006')
      end

      it "set to 'published_at' should render the publish date" do
        expect(dated).to render('<r:date for="published_at" />').as('Wednesday, January 11, 2006')
      end

      it "set to an invalid attribute should render an error" do
        expect(dated).to render('<r:date for="blah" />').with_error("Invalid value for 'for' attribute.")
      end
    end

    it "should use the currently set timezone" do
      Time.zone = "Tokyo"
      format = "%H:%m"
      expected = dated.published_at.in_time_zone(ActiveSupport::TimeZone['Tokyo']).strftime(format)
      expect(dated).to render(%Q(<r:date format="#{format}" />) ).as(expected)
    end
  end

  describe "<r:link>" do
    it "should render a link to the current page" do
      expect(page).to render('<r:link />').as('<a href="/page/">Page</a>')
    end

    it "should render its contents as the text of the link" do
      expect(page).to render('<r:link>Test</r:link>').as('<a href="/page/">Test</a>')
    end

    it "should pass HTML attributes to the <a> tag" do
      input = '<r:link class="test" id="bacon" />'
      expect(page).to render(input).matching(/\ class="test"/)
      expect(page).to render(input).matching(/\ href="\/page\/"/)
      expect(page).to render(input).matching(/\ id="bacon"/)
    end

    it "should add the anchor attribute to the link as a URL anchor" do
      expect(page).to render('<r:link anchor="test">Test</r:link>').as('<a href="/page/#test">Test</a>')
    end

    it "should render a link for the current contextual page" do
      child; child_2; child_3
      expected = %{<a href="/parent/child/">Child</a> <a href="/parent/child-2/">Child 2</a> <a href="/parent/child-3/">Child 3</a> }
      expect(parent).to render('<r:children:each><r:link /> </r:children:each>' ).as(expected)
    end

    it "should scope the link within the relative URL root" do
      expect(page).to render('<r:link />').with_relative_root('/foo').as('<a href="/foo/page/">Page</a>')
    end
  end

  it '<r:random> should render a randomly selected contained <r:option>' do
    expect(page).to render("<r:random> <r:option>1</r:option> <r:option>2</r:option> <r:option>3</r:option> </r:random>").matching(/^(1|2|3)$/)
  end

  it '<r:random> should render a randomly selected, dynamically set <r:option>' do
    child; child_2; child_3
    expect(parent).to render("<r:random:children:each:option:title />").matching(/^(Child|Child\ 2|Child\ 3)$/)
  end

  describe '<r:hide>' do
    it "should not display it's contents" do
      expect(page).to render('just a <r:hide>small </r:hide>test').as('just a test')
    end
  end

  describe "<r:navigation>" do
    it "should render the nested <r:normal> tag by default" do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted/ | Parent: /parent/">
                 <r:normal><r:title /></r:normal>
               </r:navigation>}
      expected = %{Home Assorted Parent}
      expect(page).to render(tags).as(expected)
    end

    it "should render the nested <r:selected> tag for paths that match the current page" do
      tags = %{<r:navigation paths="Home: / | Page: /page/ | Parent: /parent/ | Radius: /radius/">
                 <r:normal><r:title /></r:normal>
                 <r:selected><strong><r:title/></strong></r:selected>
               </r:navigation>}
      expected = %{<strong>Home</strong> Page <strong>Parent</strong> Radius}
      expect(parent).to render(tags).as(expected)
    end

    it "should render the nested <r:here> tag for paths that exactly match the current page" do
      tags = %{<r:navigation paths="Home: Boy: / | Page: /page/ | Parent: /parent/">
                 <r:normal><a href="<r:path />"><r:title /></a></r:normal>
                 <r:here><strong><r:title /></strong></r:here>
                 <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
                 <r:between> | </r:between>
               </r:navigation>}
      expected = %{<strong><a href="/">Home: Boy</a></strong> | <strong>Page</strong> | <a href="/parent/">Parent</a>}
      expect(page).to render(tags).as(expected)
    end

    it "should render the nested <r:between> tag between each link" do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted/ | Parent: /parent/">
                 <r:normal><r:title /></r:normal>
                 <r:between> :: </r:between>
               </r:navigation>}
      expected = %{Home :: Assorted :: Parent}
      expect(page).to render(tags).as(expected)
    end

    it 'without paths should render nothing' do
      expect(page).to render(%{<r:navigation><r:normal /></r:navigation>}).as('')
    end

    it 'without a nested <r:normal> tag should render an error' do
      expect(page).to render(%{<r:navigation paths="something:here"></r:navigation>}).with_error( "`navigation' tag must include a `normal' tag")
    end

    it 'with paths without trailing slashes should match corresponding pages' do
      tags = %{<r:navigation paths="Home: / | Page: /page | Parent: /parent | Radius: /radius">
                 <r:normal><r:title /></r:normal>
                 <r:here><strong><r:title /></strong></r:here>
               </r:navigation>}
      expected = %{Home <strong>Page</strong> Parent Radius}
      expect(page).to render(tags).as(expected)
    end

    it 'should prune empty blocks' do
      tags = %{<r:navigation paths="Home: Boy: / | Archives: /archive/ | Radius: /radius/ | Docs: /documentation/">
                 <r:normal><a href="<r:path />"><r:title /></a></r:normal>
                 <r:here></r:here>
                 <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
                 <r:between> | </r:between>
               </r:navigation>}
      expected = %{<strong><a href="/">Home: Boy</a></strong> | <a href="/archive/">Archives</a> | <a href="/documentation/">Docs</a>}
      expect(radius).to render(tags).as(expected)
    end

    it 'should render text under <r:if_first> and <r:if_last> only on the first and last item, respectively' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><r:if_first>(</r:if_first><a href="<r:path />"><r:title /></a><r:if_last>)</r:if_last></r:normal>
                 <r:here><r:if_first>(</r:if_first><r:title /><r:if_last>)</r:if_last></r:here>
                 <r:selected><r:if_first>(</r:if_first><strong><a href="<r:path />"><r:title /></a></strong><r:if_last>)</r:if_last></r:selected>
               </r:navigation>}
      expected = %{(<strong><a href=\"/\">Home</a></strong> <a href=\"/assorted\">Assorted</a> <a href=\"/parent\">Parent</a> Radius)}
      expect(radius).to render(tags).as(expected)
    end

    it 'should render text under <r:unless_first> on every item but the first' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><r:unless_first>&gt; </r:unless_first><a href="<r:path />"><r:title /></a></r:normal>
                 <r:here><r:unless_first>&gt; </r:unless_first><r:title /></r:here>
                 <r:selected><r:unless_first>&gt; </r:unless_first><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
               </r:navigation>}
      expected = %{<strong><a href=\"/\">Home</a></strong> &gt; <a href=\"/assorted\">Assorted</a> &gt; <a href=\"/parent\">Parent</a> &gt; Radius}
      expect(radius).to render(tags).as(expected)
    end

    it 'should render text under <r:unless_last> on every item but the last' do
      tags = %{<r:navigation paths="Home: / | Assorted: /assorted | Parent: /parent | Radius: /radius">
                 <r:normal><a href="<r:path />"><r:title /></a><r:unless_last> &gt;</r:unless_last></r:normal>
                 <r:here><r:title /><r:unless_last> &gt;</r:unless_last></r:here>
                 <r:selected><strong><a href="<r:path />"><r:title /></a></strong><r:unless_last> &gt;</r:unless_last></r:selected>
               </r:navigation>}
      expected = %{<strong><a href=\"/\">Home</a></strong> &gt; <a href=\"/assorted\">Assorted</a> &gt; <a href=\"/parent\">Parent</a> &gt; Radius}
      expect(radius).to render(tags).as(expected)
    end
  end

  describe "<r:find>" do
    it "should change the local page to the page specified in the 'path' attribute" do
      home; parent; child
      expect(page).to render(%{<r:find path="/parent/child/"><r:title /></r:find>}).as('Child')
    end

    it "should render an error without a 'path' or 'url' attribute" do
      expect(page).to render(%{<r:find />}).with_error("`find' tag must contain a `path' or `url' attribute.")
    end

    it "should render nothing when the 'path' attribute does not point to a page" do
      expect(page).to render(%{<r:find path="/asdfsdf/"><r:title /></r:find>}).as('')
    end

    it "should render nothing when the 'path' attribute does not point to a page and a custom 404 page exists" do
      expect(page).to render(%{<r:find path="/gallery/asdfsdf/"><r:title /></r:find>}).as('')
    end

    it "should scope contained tags to the found page" do
      home; parent; child; child_2; child_3
      expect(page).to render(%{<r:find path="/parent/"><r:children:each><r:slug /> </r:children:each></r:find>}).as('child child-2 child-3 ')
    end

    it "should accept a path relative to the current page" do
      home; parent; child; grandchild; child_2
      expect(great_grandchild).to render(%{<r:find path="../../../child-2"><r:title/></r:find>}).as("Child 2")
    end
  end

  it '<r:escape_html> should escape HTML-related characters into entities' do
    expect(page).to render('<r:escape_html><strong>a bold move</strong></r:escape_html>').as('&lt;strong&gt;a bold move&lt;/strong&gt;')
  end

  describe "<r:breadcrumbs>" do
    it "should render a series of breadcrumb links separated by &gt;" do
      expected = %{<a href="/">Home</a> &gt; <a href="/parent/">Parent</a> &gt; <a href="/parent/child/">Child</a> &gt; <a href="/parent/child/grandchild/">Grandchild</a> &gt; Great Grandchild}
      expect(great_grandchild).to render('<r:breadcrumbs />').as(expected)
    end

    it "with a 'separator' attribute should use the separator instead of &gt;" do
      expected = %{<a href="/">Home</a> :: Parent}
      expect(parent).to render('<r:breadcrumbs separator=" :: " />').as(expected)
    end

    it "with a 'nolinks' attribute set to 'true' should not render links" do
      expected = %{Home &gt; Parent}
      expect(parent).to render('<r:breadcrumbs nolinks="true" />').as(expected)
    end

    it "with a relative URL root should scope links to the relative root" do
      expected = '<a href="/foo/">Home</a> &gt; Page'
      expect(page).to render('<r:breadcrumbs />').with_relative_root('/foo').as(expected)
    end
  end

  describe "<r:if_path>" do
    describe "with 'matches' attribute" do
      it "should render the contained block if the page URL matches" do
        expect(page).to render('<r:if_path matches="p.ge/$">true</r:if_path>').as('true')
      end

      it "should not render the contained block if the page URL does not match" do
        expect(page).to render('<r:if_path matches="fancypants">true</r:if_path>').as('')
      end

      it "set to a malformatted regexp should render an error" do
        expected_error = "Malformed regular expression in `matches' argument of `if_path' tag: " + (RUBY_VERSION =~ /^1\.9/ ? "unmatched (: /p(ge\\/$/" :  "end pattern with unmatched parenthesis: /p(ge\\/$/i")
        expect(page).to render('<r:if_path matches="p(ge/$">true</r:if_path>').with_error(expected_error)
      end

      it "without 'ignore_case' attribute should ignore case by default" do
        expect(page).to render('<r:if_path matches="pAgE/$">true</r:if_path>').as('true')
      end

      describe "with 'ignore_case' attribute" do
        it "set to 'true' should use a case-insensitive match" do
          expect(page).to render('<r:if_path matches="pAgE/$" ignore_case="true">true</r:if_path>').as('true')
        end

        it "set to 'false' should use a case-sensitive match" do
          expect(page).to render('<r:if_path matches="pAgE/$" ignore_case="false">true</r:if_path>').as('')
        end
      end
    end

    it "with no attributes should render an error" do
      expect(page).to render('<r:if_path>test</r:if_path>').with_error("`if_path' tag must contain a `matches' attribute.")
    end
  end

  describe "<r:unless_path>" do
    describe "with 'matches' attribute" do
      it "should not render the contained block if the page URL matches" do
        expect(page).to render('<r:unless_path matches="p.ge/$">true</r:unless_path>').as('')
      end

      it "should render the contained block if the page URL does not match" do
        expect(page).to render('<r:unless_path matches="fancypants">true</r:unless_path>').as('true')
      end

      it "set to a malformatted regexp should render an error" do
        expected_error = "Malformed regular expression in `matches' argument of `unless_path' tag: " + (RUBY_VERSION =~ /^1\.9/ ? "unmatched (: /p(ge\\/$/" :  "end pattern with unmatched parenthesis: /p(ge\\/$/i")
        expect(page).to render('<r:unless_path matches="p(ge/$">true</r:unless_path>').with_error(expected_error)
      end

      it "without 'ignore_case' attribute should ignore case by default" do
        expect(page).to render('<r:unless_path matches="pAgE/$">true</r:unless_path>').as('')
      end

      describe "with 'ignore_case' attribute" do
        it "set to 'true' should use a case-insensitive match" do
          expect(page).to render('<r:unless_path matches="pAgE/$">true</r:unless_path>').as('')
        end

        it "set to 'false' should use a case-sensitive match" do
          expect(page).to render('<r:unless_path matches="pAgE/$" ignore_case="false">true</r:unless_path>').as('true')
        end
      end
    end

    it "with no attributes should render an error" do
      expect(page).to render('<r:unless_path>test</r:unless_path>').with_error("`unless_path' tag must contain a `matches' attribute.")
    end
  end

  describe "<r:cycle>" do
    subject { page }
    it "should render passed values in succession" do
      expect(page).to render('<r:cycle values="first, second" /> <r:cycle values="first, second" />').as('first second')
    end

    it "should return to the beginning of the cycle when reaching the end" do
      expect(page).to render('<r:cycle values="first, second" /> <r:cycle values="first, second" /> <r:cycle values="first, second" />').as('first second first')
    end

    it "should start at a given start value" do
      expect(page).to render('<r:cycle values="first, second, third" start="second" /> <r:cycle values="first, second, third" start="second" /> <r:cycle values="first, second, third" start="second" />').as('second third first')
    end

    it "should use a default cycle name of 'cycle'" do
      expect(page).to render('<r:cycle values="first, second" /> <r:cycle values="first, second" name="cycle" />').as('first second')
    end

    it "should maintain separate cycle counters" do
      expect(page).to render('<r:cycle values="first, second" /> <r:cycle values="one, two" name="numbers" /> <r:cycle values="first, second" /> <r:cycle values="one, two" name="numbers" />').as('first one second two')
    end

    it "should reset the counter" do
      expect(page).to render('<r:cycle values="first, second" /> <r:cycle values="first, second" reset="true"/>').as('first first')
    end

    it { is_expected.to render('<r:cycle /> <r:cycle />').as('0 1') }
    it { is_expected.to render('<r:cycle start="3" /> <r:cycle start="3" /> <r:cycle start="3" />').as('3 4 5') }
    it { is_expected.to render('<r:cycle start="3" /> <r:cycle name="other" /> <r:cycle start="3" />').as('3 0 4') }
    it { is_expected.to render('<r:cycle start="3" /> <r:cycle name="other" start="23" /> <r:cycle />').as('3 23 4') }
    it { is_expected.to render('<r:cycle start="3" /> <r:cycle name="other" start="23" /> <r:cycle reset="true" />').as('3 23 0') }
  end

  describe "<r:if_dev>" do
    it "should render the contained block when on the dev site" do
      expect(page).to render('-<r:if_dev>dev</r:if_dev>-').as('-dev-').on('dev.site.com')
    end

    it "should not render the contained block when not on the dev site" do
      expect(page).to render('-<r:if_dev>dev</r:if_dev>-').as('--')
    end

    it "should not render the contained block when no request is present" do
      expect(devtags.render_part('if_dev')).not_to eq('dev')
    end

    describe "on an included page" do
      it "should render the contained block when on the dev site" do
        devtags
        expect(page).to render('-<r:find path="/devtags/"><r:content part="if_dev" />-</r:find>').as('-dev-').on('dev.site.com')
      end

      it "should not render the contained block when not on the dev site" do
        devtags
        expect(page).to render('<r:find path="/devtags/">-<r:content part="if_dev" />-</r:find>').as('--')
      end
    end
  end

  describe "<r:unless_dev>" do
    it "should not render the contained block when not on the dev site" do
      expect(page).to render('-<r:unless_dev>not dev</r:unless_dev>-').as('--').on('dev.site.com')
    end

    it "should render the contained block when not on the dev site" do
      expect(page).to render('-<r:unless_dev>not dev</r:unless_dev>-').as('-not dev-')
    end

    it "should render the contained block when no request is present" do
      expect(devtags.render_part('unless_dev')).to eq('not dev')
    end

    describe "on an included page" do
      it "should not render the contained block when not on the dev site" do
        devtags
        expect(page).to render('<r:find path="/devtags/">-<r:content part="unless_dev" />-</r:find>').as('--').on('dev.site.com')
      end

      it "should render the contained block when not on the dev site" do
        devtags
        # @page = ?
        expect(page).to render('<r:find path="/devtags/">-<r:content part="unless_dev" />-</r:find>').as('-not dev-')
      end
    end
  end

  describe "<r:status>" do
    let(:hidden){ FactoryGirl.build(:page, status: Status[:hidden])}
    let(:draft){ FactoryGirl.build(:page, status: Status[:draft])}
    
    it "should render the status of the current page" do
      status_tag = "<r:status/>"
      expect(home).to render(status_tag).as("Published")
      expect(hidden).to render(status_tag).as("Hidden")
      expect(draft).to render(status_tag).as("Draft")
    end

    describe "with the downcase attribute set to 'true'" do
      it "should render the lowercased status of the current page" do
        status_tag_lc = "<r:status downcase='true'/>"
        expect(home).to render(status_tag_lc).as("published")
        expect(hidden).to render(status_tag_lc).as("hidden")
        expect(draft).to render(status_tag_lc).as("draft")
      end
    end
  end

  describe "<r:if_ancestor_or_self>" do
    it "should render the tag's content when the current page is an ancestor of tag.locals.page" do
      expect(radius).to render(%{<r:find path="/"><r:if_ancestor_or_self>true</r:if_ancestor_or_self></r:find>}).as('true')
    end

    it "should not render the tag's content when current page is not an ancestor of tag.locals.page" do
      expect(parent).to render(%{<r:find path="/radius"><r:if_ancestor_or_self>true</r:if_ancestor_or_self></r:find>}).as('')
    end
  end

  describe "<r:unless_ancestor_or_self>" do
    it "should render the tag's content when the current page is not an ancestor of tag.locals.page" do
      radius
      expect(parent).to render(%{<r:find path="/radius"><r:unless_ancestor_or_self>true</r:unless_ancestor_or_self></r:find>}).as('true')
    end

    it "should not render the tag's content when current page is an ancestor of tag.locals.page" do
      expect(radius).to render(%{<r:find path="/"><r:unless_ancestor_or_self>true</r:unless_ancestor_or_self></r:find>}).as('')
    end
  end

  describe "<r:if_self>" do
    it "should render the tag's content when the current page is the same as the local contextual page" do
      expect(home).to render(%{<r:find path="/"><r:if_self>true</r:if_self></r:find>}).as('true')
    end

    it "should not render the tag's content when the current page is not the same as the local contextual page" do
      expect(radius).to render(%{<r:find path="/"><r:if_self>true</r:if_self></r:find>}).as('')
    end
  end

  describe "<r:unless_self>" do
    it "should render the tag's content when the current page is not the same as the local contextual page" do
      expect(radius).to render(%{<r:find path="/"><r:unless_self>true</r:unless_self></r:find>}).as('true')
    end

    it "should not render the tag's content when the current page is the same as the local contextual page" do
      expect(home).to render(%{<r:find path="/"><r:unless_self>true</r:unless_self></r:find>}).as('')
    end
  end

  describe "Field tags" do
    subject{
      p = Page.new(slug: "/", parent_id: nil, title: 'Home')
      field = PageField.new(name: 'Field', content: "Sweet harmonious biscuits")
      blank_field = PageField.new(name: 'blank', content: "")
      p.fields = [field, blank_field]
      p
    }

    describe '<r:field>' do
      it { is_expected.to render('<r:field name="field" />').as('Sweet harmonious biscuits') }
      it { is_expected.to render('<r:field name="bogus" />').as('') }
    end

    describe "<r:if_field>" do
      it { is_expected.to render('<r:if_field name="field">Ok</r:if_field>').as('Ok') }
      it { is_expected.to render('<r:if_field name="bogus">Ok</r:if_field>').as('') }
      it { is_expected.to render('<r:if_field name="field" equals="sweet harmonious biscuits">Ok</r:if_field>').as('Ok') }
      it { is_expected.to render('<r:if_field name="bogus" equals="sweet harmonious biscuits">Ok</r:if_field>').as('') }
      it { is_expected.to render('<r:if_field name="field" equals="sweet harmonious biscuits" ignore_case="false">Ok</r:if_field>').as('') }
      it { is_expected.to render('<r:if_field name="field" matches="^sweet\s">Ok</r:if_field>').as('Ok') }
      it { is_expected.to render('<r:if_field name="field" matches="^sweet\s" ignore_case="false">Ok</r:if_field>').as('') }
      it { is_expected.to render('<r:if_field name="blank" matches="[^\s]">Not here</r:if_field>').as('') }
      it { is_expected.to render('<r:if_field name="bogus" matches="something">Not here</r:if_field>').as('') }
    end

    describe "<r:unless_field>" do
      it { is_expected.to render('<r:unless_field name="field">Ok</r:unless_field>').as('') }
      it { is_expected.to render('<r:unless_field name="bogus">Ok</r:unless_field>').as('Ok') }
      it { is_expected.to render('<r:unless_field name="field" equals="sweet harmonious biscuits">Ok</r:unless_field>').as('') }
      it { is_expected.to render('<r:unless_field name="bogus" equals="sweet harmonious biscuits">Ok</r:unless_field>').as('Ok') }
      it { is_expected.to render('<r:unless_field name="field" equals="sweet harmonious biscuits" ignore_case="false">Ok</r:unless_field>').as('Ok') }
      it { is_expected.to render('<r:unless_field name="field" matches="^sweet\s">Ok</r:unless_field>').as('') }
      it { is_expected.to render('<r:unless_field name="field" matches="^sweet\s" ignore_case="false">Ok</r:unless_field>').as('Ok') }
      it { is_expected.to render('<r:unless_field name="blank" matches="[^\s]">Not here</r:unless_field>').as('Not here') }
      it { is_expected.to render('<r:unless_field name="bogus" matches="something">Not here</r:unless_field>').as('Not here') }
    end

  end

  private

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
