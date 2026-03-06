require "test_helper"

class DeprecatedTagsTest < ActiveSupport::TestCase
  setup do
    @page = prepare_page_for_render(:home)
  end

  test "meta tag renders meta tags for fields" do
    # deprecated_tags.rb looks up fields by :description and :keywords (lowercase)
    @page.fields.create!(name: "keywords", content: "Home, Page")
    @page.fields.create!(name: "description", content: "The homepage")
    @page.parts.find_by(name: "body").update!(content: '<r:meta/>')
    result = @page.render_part(:body)
    assert_includes result, 'meta name="description"'
    assert_includes result, 'meta name="keywords"'
  end

  test "meta description tag renders only description" do
    @page.fields.create!(name: "description", content: "The homepage")
    @page.parts.find_by(name: "body").update!(content: '<r:meta:description/>')
    result = @page.render_part(:body)
    assert_includes result, 'meta name="description"'
    assert_includes result, "The homepage"
  end

  test "meta keywords tag renders only keywords" do
    @page.fields.create!(name: "keywords", content: "test, keys")
    @page.parts.find_by(name: "body").update!(content: '<r:meta:keywords/>')
    result = @page.render_part(:body)
    assert_includes result, 'meta name="keywords"'
    assert_includes result, "test, keys"
  end

  test "meta tag with tag=false renders content without html" do
    @page.fields.create!(name: "description", content: "The homepage")
    @page.parts.find_by(name: "body").update!(content: '<r:meta:description tag="false" />')
    result = @page.render_part(:body)
    assert_equal "The homepage", result
  end

  test "meta tag escapes HTML entities" do
    @page.fields.create!(name: "keywords", content: "sweet & harmonious")
    @page.parts.find_by(name: "body").update!(content: '<r:meta:keywords/>')
    result = @page.render_part(:body)
    assert_includes result, "sweet &amp; harmonious"
  end
end
