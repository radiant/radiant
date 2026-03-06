require "test_helper"

class PageContextTest < ActiveSupport::TestCase
  setup do
    @page = pages(:radius)
    @page.request = ActionDispatch::TestRequest.create
    @page.response = ActionDispatch::TestResponse.new
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, tag_prefix: 'r')
  end

  test "initializes with a page" do
    assert_equal @page, @parser.context.page
  end

  test "raises error for missing tag" do
    assert_raises(StandardTags::TagError) { @parser.parse('<r:missing />') }
  end

  test "gives tags access to the request" do
    @parser.context.define_tag("if_request") { |tag| tag.expand if tag.locals.page.request }
    result = @parser.parse('<r:if_request>found</r:if_request>')
    assert_includes result, "found"
  end

  test "gives tags access to the response" do
    @parser.context.define_tag("if_response") { |tag| tag.expand if tag.locals.page.response }
    result = @parser.parse('<r:if_response>found</r:if_response>')
    assert_includes result, "found"
  end
end
