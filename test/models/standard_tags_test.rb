require "test_helper"

class StandardTagsTest < ActiveSupport::TestCase
  fixtures :pages, :page_parts, :snippets, :layouts, :users

  def setup
    @page = prepare_page_for_render(:home)
  end

  def render_tag(tag_content, page = @page)
    part = page.parts.find_or_create_by!(name: "body")
    part.update!(content: tag_content) if part.content != tag_content
    page.render_part(:body)
  end

  # ===========================================================================
  # 1. Basic attribute tags
  # ===========================================================================

  test "r:title renders the page title" do
    assert_equal "Home", render_tag('<r:title />')
  end

  test "r:title renders title for child page" do
    page = prepare_page_for_render(:first)
    assert_equal "First", render_tag('<r:title />', page)
  end

  test "r:slug renders the page slug" do
    assert_equal "/", render_tag('<r:slug />')
  end

  test "r:slug renders child page slug" do
    page = prepare_page_for_render(:first)
    assert_equal "first", render_tag('<r:slug />', page)
  end

  test "r:breadcrumb renders the breadcrumb attribute" do
    assert_equal "Home", render_tag('<r:breadcrumb />')
  end

  test "r:breadcrumb for child page" do
    page = prepare_page_for_render(:first)
    assert_equal "First", render_tag('<r:breadcrumb />', page)
  end

  test "r:path renders the page path" do
    assert_equal "/", render_tag('<r:path />')
  end

  test "r:path renders child page path" do
    page = prepare_page_for_render(:first)
    assert_equal "/first/", render_tag('<r:path />', page)
  end

  test "r:path renders deeply nested page path" do
    page = prepare_page_for_render(:grandchild)
    assert_equal "/parent/child/grandchild/", render_tag('<r:path />', page)
  end

  # ===========================================================================
  # 2. Content tags
  # ===========================================================================

  test "r:content renders body part by default" do
    result = @page.render_part(:body)
    assert_equal "Hello world!", result
  end

  test "r:content renders sidebar part" do
    result = @page.render_part(:sidebar)
    assert_equal "Home sidebar.", result
  end

  test "r:content with part attribute renders named part" do
    page = prepare_page_for_render(:party)
    assert_equal "favors", render_tag('<r:content part="favors" />', page)
  end

  test "r:content with part attribute renders games part" do
    page = prepare_page_for_render(:party)
    assert_equal "games", render_tag('<r:content part="games" />', page)
  end

  test "r:content renders extended part on home page" do
    result = @page.render_part(:extended)
    assert_equal "Just a test.", result
  end

  # ===========================================================================
  # 3. Parent/child tags
  # ===========================================================================

  test "r:parent:title renders parent page title" do
    page = prepare_page_for_render(:first)
    assert_equal "Home", render_tag('<r:parent><r:title /></r:parent>', page)
  end

  test "r:parent:title for deeply nested page" do
    page = prepare_page_for_render(:grandchild)
    assert_equal "Child", render_tag('<r:parent><r:title /></r:parent>', page)
  end

  test "r:if_parent renders content when page has a parent" do
    page = prepare_page_for_render(:first)
    assert_equal "yes", render_tag('<r:if_parent>yes</r:if_parent>', page)
  end

  test "r:if_parent does not render for root page" do
    result = render_tag('<r:if_parent>yes</r:if_parent>')
    assert_equal "", result
  end

  test "r:unless_parent renders content when page has no parent" do
    assert_equal "root", render_tag('<r:unless_parent>root</r:unless_parent>')
  end

  test "r:unless_parent does not render for child page" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:unless_parent>root</r:unless_parent>', page)
    assert_equal "", result
  end

  test "r:children:each iterates over published children" do
    result = render_tag('<r:children:each><r:title /> </r:children:each>')
    assert_match(/\w+/, result)
  end

  test "r:children:each by title asc" do
    result = render_tag('<r:children:each by="title" order="asc"><r:title /> </r:children:each>')
    assert_match(/\w+/, result)
  end

  test "r:children:first renders first child" do
    result = render_tag('<r:children:first><r:title /></r:children:first>')
    assert_match(/\w+/, result)
  end

  test "r:children:last renders last child" do
    result = render_tag('<r:children:last><r:title /></r:children:last>')
    assert_match(/\w+/, result)
  end

  test "r:children:count renders number of published children" do
    result = render_tag('<r:children:count />')
    assert_match(/\d+/, result)
  end

  test "r:children:count for home page includes published children" do
    result = render_tag('<r:children:count />')
    assert result.to_i > 0, "Home page should have children"
  end

  test "r:children:count for childless page returns 0" do
    page = prepare_page_for_render(:childless)
    result = render_tag('<r:children:count />', page)
    assert_equal "0", result
  end

  # ===========================================================================
  # 4. Find tag
  # ===========================================================================

  test "r:find locates page by absolute path" do
    result = render_tag('<r:find path="/parent/child/"><r:title /></r:find>')
    assert_equal "Child", result
  end

  test "r:find locates deeply nested page" do
    result = render_tag('<r:find path="/parent/child/grandchild/"><r:title /></r:find>')
    assert_equal "Grandchild", result
  end

  test "r:find locates root page" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:find path="/"><r:title /></r:find>', page)
    assert_equal "Home", result
  end

  test "r:find renders nothing for nonexistent path" do
    result = render_tag('<r:find path="/nonexistent/"><r:title /></r:find>')
    assert_equal "", result
  end

  # ===========================================================================
  # 5. Conditional tags
  # ===========================================================================

  test "r:if_content renders when body part exists" do
    assert_equal "yes", render_tag('<r:if_content>yes</r:if_content>')
  end

  test "r:if_content with named part renders when part exists" do
    assert_equal "yes", render_tag('<r:if_content part="sidebar">yes</r:if_content>')
  end

  test "r:if_content does not render when part does not exist" do
    result = render_tag('<r:if_content part="nonexistent">yes</r:if_content>')
    assert_equal "", result
  end

  test "r:if_content with multiple parts and find all" do
    result = render_tag('<r:if_content part="body, sidebar">both</r:if_content>')
    assert_equal "both", result
  end

  test "r:if_content with multiple parts find any" do
    result = render_tag('<r:if_content part="body, nonexistent" find="any">found</r:if_content>')
    assert_equal "found", result
  end

  test "r:unless_content renders when part does not exist" do
    result = render_tag('<r:unless_content part="nonexistent">missing</r:unless_content>')
    assert_equal "missing", result
  end

  test "r:unless_content does not render when part exists" do
    result = render_tag('<r:unless_content part="sidebar">missing</r:unless_content>')
    assert_equal "", result
  end

  test "r:if_children renders when page has children" do
    result = render_tag('<r:if_children>has kids</r:if_children>')
    assert_equal "has kids", result
  end

  test "r:if_children does not render when page has no children" do
    page = prepare_page_for_render(:childless)
    result = render_tag('<r:if_children>has kids</r:if_children>', page)
    assert_equal "", result
  end

  test "r:unless_children renders when page has no children" do
    page = prepare_page_for_render(:childless)
    result = render_tag('<r:unless_children>no kids</r:unless_children>', page)
    assert_equal "no kids", result
  end

  test "r:unless_children does not render when page has children" do
    result = render_tag('<r:unless_children>no kids</r:unless_children>')
    assert_equal "", result
  end

  # ===========================================================================
  # 6. Date tag
  # ===========================================================================

  test "r:date renders published_at date with default format" do
    page = prepare_page_for_render(:dated)
    result = render_tag('<r:date />', page)
    # Default format is "%A, %B %d, %Y" -- published_at is 2006-01-11
    assert_includes result, "2006"
    assert_includes result, "January"
    assert_includes result, "11"
  end

  test "r:date with custom format" do
    page = prepare_page_for_render(:dated)
    result = render_tag('<r:date format="%Y-%m-%d" />', page)
    assert_equal "2006-01-11", result
  end

  test "r:date for created_at" do
    page = prepare_page_for_render(:dated)
    result = render_tag('<r:date for="created_at" format="%Y-%m-%d" />', page)
    assert_equal "2006-01-10", result
  end

  test "r:date for updated_at" do
    page = prepare_page_for_render(:dated)
    result = render_tag('<r:date for="updated_at" format="%Y-%m-%d" />', page)
    assert_equal "2006-01-12", result
  end

  test "r:date for now renders current date" do
    result = render_tag('<r:date for="now" format="%Y" />')
    assert_equal Time.zone.now.year.to_s, result
  end

  test "r:date raises error for invalid for attribute" do
    assert_raises(StandardTags::TagError) do
      render_tag('<r:date for="invalid_column" />')
    end
  end

  # ===========================================================================
  # 7. Link tag
  # ===========================================================================

  test "r:link renders link with page title" do
    result = render_tag('<r:link />')
    assert_includes result, "<a href"
    assert_includes result, "Home"
    assert_includes result, "/"
  end

  test "r:link with custom text" do
    result = render_tag('<r:link>Click here</r:link>')
    assert_includes result, "Click here"
    assert_includes result, "<a href"
  end

  test "r:link with anchor attribute" do
    result = render_tag('<r:link anchor="section1" />')
    assert_includes result, "#section1"
  end

  test "r:link with class attribute" do
    result = render_tag('<r:link class="nav" />')
    assert_includes result, 'class="nav"'
  end

  test "r:link for child page" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:link />', page)
    assert_includes result, "/first/"
    assert_includes result, "First"
  end

  # ===========================================================================
  # 8. Breadcrumbs
  # ===========================================================================

  test "r:breadcrumbs renders trail for home page" do
    result = render_tag('<r:breadcrumbs />')
    assert_includes result, "Home"
  end

  test "r:breadcrumbs renders trail for child page" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:breadcrumbs />', page)
    assert_includes result, "Home"
    assert_includes result, "First"
    assert_includes result, "<a href"
  end

  test "r:breadcrumbs renders trail for deeply nested page" do
    page = prepare_page_for_render(:grandchild)
    result = render_tag('<r:breadcrumbs />', page)
    assert_includes result, "Home"
    assert_includes result, "Parent"
    assert_includes result, "Child"
    assert_includes result, "Grandchild"
  end

  test "r:breadcrumbs with custom separator" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:breadcrumbs separator=" / " />', page)
    assert_includes result, " / "
  end

  test "r:breadcrumbs with nolinks" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:breadcrumbs nolinks="true" />', page)
    assert_not_includes result, "<a href"
    assert_includes result, "Home"
    assert_includes result, "First"
  end

  test "r:breadcrumbs with noself" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:breadcrumbs noself="true" />', page)
    assert_includes result, "Home"
    assert_not_includes result, "First"
  end

  # ===========================================================================
  # 9. Escape/comment/hide
  # ===========================================================================

  test "r:escape_html escapes angle brackets" do
    result = render_tag('<r:escape_html><b>bold</b></r:escape_html>')
    assert_includes result, "&lt;b&gt;bold&lt;/b&gt;"
    assert_not_includes result, "<b>bold</b>"
  end

  test "r:escape_html escapes ampersands" do
    result = render_tag('<r:escape_html>A & B</r:escape_html>')
    assert_includes result, "&amp;"
  end

  test "r:hide renders nothing" do
    result = render_tag('<r:hide>This should not appear</r:hide>')
    assert_equal "", result
  end

  test "r:hide with nested tags renders nothing" do
    result = render_tag('<r:hide><r:title /> should not appear</r:hide>')
    assert_equal "", result
  end

  # ===========================================================================
  # 10. Cycle tag
  # ===========================================================================

  test "r:cycle with values cycles through options" do
    result = render_tag('<r:children:each><r:cycle values="a,b" /> </r:children:each>')
    assert_includes result, "a"
    assert_includes result, "b"
  end

  test "r:cycle without values returns incrementing counter" do
    result = render_tag('<r:children:each><r:cycle /> </r:children:each>')
    assert_includes result, "1"
    assert_includes result, "2"
  end

  # ===========================================================================
  # 11. Status tag
  # ===========================================================================

  test "r:status renders Published for published page" do
    result = render_tag('<r:status />')
    assert_equal "Published", result
  end

  test "r:status with downcase attribute" do
    result = render_tag('<r:status downcase="true" />')
    assert_equal "published", result
  end

  test "r:status renders Draft for draft page" do
    page = prepare_page_for_render(:draft)
    result = render_tag('<r:status />', page)
    assert_equal "Draft", result
  end

  test "r:status renders Hidden for hidden page" do
    page = prepare_page_for_render(:hidden)
    result = render_tag('<r:status />', page)
    assert_equal "Hidden", result
  end

  # ===========================================================================
  # 12. Snippet tag -- no snippet tag defined in StandardTags
  #     Snippets are rendered via r:content which calls render_snippet
  # ===========================================================================

  # ===========================================================================
  # 13. If_path / unless_path
  # ===========================================================================

  test "r:if_path matches current page path" do
    result = render_tag('<r:if_path matches="^/$">root</r:if_path>')
    assert_equal "root", result
  end

  test "r:if_path does not match different path" do
    result = render_tag('<r:if_path matches="/other/">nope</r:if_path>')
    assert_equal "", result
  end

  test "r:if_path matches child page path" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:if_path matches="first">yes</r:if_path>', page)
    assert_equal "yes", result
  end

  test "r:if_path with regex pattern" do
    page = prepare_page_for_render(:child)
    result = render_tag('<r:if_path matches="parent/child">matched</r:if_path>', page)
    assert_equal "matched", result
  end

  test "r:unless_path renders when path does not match" do
    result = render_tag('<r:unless_path matches="/other/">not other</r:unless_path>')
    assert_equal "not other", result
  end

  test "r:unless_path does not render when path matches" do
    result = render_tag('<r:unless_path matches="^/$">not root</r:unless_path>')
    assert_equal "", result
  end

  # ===========================================================================
  # 14. Page context
  # ===========================================================================

  test "r:page:title renders current page title" do
    assert_equal "Home", render_tag('<r:page><r:title /></r:page>')
  end

  test "r:page:title inside find still refers to actual page" do
    page = prepare_page_for_render(:first)
    result = render_tag('<r:find path="/parent/child/"><r:page><r:title /></r:page></r:find>', page)
    assert_equal "First", result
  end

  # ===========================================================================
  # 15. Field tags
  # ===========================================================================

  test "r:field renders field content" do
    page = prepare_page_for_render(:home)
    page.fields.find_or_create_by!(name: "Keywords").update!(content: "cms, radiant")
    result = render_tag('<r:field name="Keywords" />', page)
    assert_equal "cms, radiant", result
  end

  test "r:field returns empty for nonexistent field" do
    result = render_tag('<r:field name="nonexistent" />')
    # May return nil or empty string depending on implementation
    assert [nil, ""].include?(result), "Expected nil or empty string, got: #{result.inspect}"
  end

  test "r:if_field renders when field exists" do
    page = prepare_page_for_render(:home)
    page.fields.find_or_create_by!(name: "author").update!(content: "John")
    result = render_tag('<r:if_field name="author">has author</r:if_field>', page)
    assert_equal "has author", result
  end

  test "r:if_field with equals attribute" do
    page = prepare_page_for_render(:home)
    page.fields.find_or_create_by!(name: "author").update!(content: "John")
    result = render_tag('<r:if_field name="author" equals="John">matched</r:if_field>', page)
    assert_equal "matched", result
  end

  test "r:if_field with equals attribute not matching" do
    page = prepare_page_for_render(:home)
    page.fields.find_or_create_by!(name: "author").update!(content: "John")
    result = render_tag('<r:if_field name="author" equals="Jane">matched</r:if_field>', page)
    assert_equal "", result
  end

  test "r:unless_field renders when field does not exist" do
    result = render_tag('<r:unless_field name="nonexistent">missing</r:unless_field>')
    assert_equal "missing", result
  end

  test "r:unless_field does not render when field exists" do
    page = prepare_page_for_render(:home)
    page.fields.find_or_create_by!(name: "author").update!(content: "John")
    result = render_tag('<r:unless_field name="author">missing</r:unless_field>', page)
    assert_equal "", result
  end

  # ===========================================================================
  # 16. Random tag
  # ===========================================================================

  test "r:random renders one of the options" do
    result = render_tag('<r:random><r:option>alpha</r:option><r:option>beta</r:option></r:random>')
    assert_includes %w[alpha beta], result
  end

  test "r:random with single option always renders that option" do
    result = render_tag('<r:random><r:option>only</r:option></r:random>')
    assert_equal "only", result
  end

  # ===========================================================================
  # Additional tag tests
  # ===========================================================================

  test "r:children:each:if_first renders for first child only" do
    result = render_tag('<r:children:each><r:if_first>FIRST </r:if_first><r:title /> </r:children:each>')
    assert_match(/\AFIRST /, result)
    # FIRST should only appear once
    assert_equal 1, result.scan("FIRST").size
  end

  test "r:children:each:if_last renders for last child only" do
    result = render_tag('<r:children:each><r:if_last>LAST </r:if_last><r:title /> </r:children:each>')
    assert_includes result, "LAST"
    assert_equal 1, result.scan("LAST").size
  end

  test "r:children:each:unless_first does not render for first child" do
    result = render_tag('<r:children:each><r:unless_first>NOT_FIRST </r:unless_first><r:title /> </r:children:each>')
    # NOT_FIRST should not appear before the first child's title
    refute_match(/\ANOT_FIRST/, result)
  end

  test "r:if_self renders when contextual page is actual page" do
    result = render_tag('<r:if_self>self</r:if_self>')
    assert_equal "self", result
  end

  test "r:unless_self does not render when contextual page is actual page" do
    result = render_tag('<r:unless_self>not self</r:unless_self>')
    assert_equal "", result
  end

  test "r:site:title renders site title config" do
    Radiant::Config["site.title"] = "Test Site"
    result = render_tag('<r:site:title />')
    assert_equal "Test Site", result
  end

  test "multiple tags in same content all render" do
    result = render_tag('<r:title /> - <r:slug />')
    assert_equal "Home - /", result
  end

  test "nested tags render correctly" do
    page = prepare_page_for_render(:child)
    result = render_tag('<r:parent><r:parent><r:title /></r:parent></r:parent>', page)
    assert_equal "Home", result
  end

  test "r:children:each with limit attribute" do
    result = render_tag('<r:children:each limit="1"><r:title /> </r:children:each>')
    titles = result.strip.split(/\s+/)
    assert_equal 1, titles.size
  end

  test "r:children:each with order desc by title" do
    result_asc = render_tag('<r:children:each by="title" order="asc"><r:title />|</r:children:each>')
    result_desc = render_tag('<r:children:each by="title" order="desc"><r:title />|</r:children:each>')
    titles_asc = result_asc.split("|").map(&:strip).reject(&:empty?)
    titles_desc = result_desc.split("|").map(&:strip).reject(&:empty?)
    assert_equal titles_asc.reverse, titles_desc
  end

  test "r:content with inherit attribute finds parent part" do
    page = prepare_page_for_render(:child)
    result = render_tag('<r:content part="sidebar" inherit="true" />', page)
    # Child has no sidebar, should inherit from home which has sidebar
    assert_includes result, "sidebar"
  end

  test "radius tag renders title via tag" do
    page = prepare_page_for_render(:radius)
    result = page.render_part(:body)
    assert_equal "Radius", result
  end
end
