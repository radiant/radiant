require "test_helper"

class NavigationTagsTest < ActiveSupport::TestCase
  setup do
    @page = prepare_page_for_render(:home)
  end

  test "navigation tag renders normal state for unrelated pages" do
    page = prepare_page_for_render(:first)

    content = %{<r:navigation paths="Home: / | News: /news">
      <r:normal><a href="<r:path />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><em><r:title /></em></r:selected>
    </r:navigation>}

    page.parts.find_by(name: "body").update!(content: content)
    result = page.render_part(:body)

    # /first doesn't match / or /news, so both should be normal links
    assert_includes result, "<a href"
    assert_includes result, "Home"
    assert_includes result, "News"
  end

  test "navigation tag renders here state for exact match" do
    content = %{<r:navigation paths="Home: / | First: /first">
      <r:normal>[normal:<r:title />]</r:normal>
      <r:here>[here:<r:title />]</r:here>
      <r:selected>[selected:<r:title />]</r:selected>
    </r:navigation>}

    @page.parts.find_by(name: "body").update!(content: content)
    result = @page.render_part(:body)

    # Home page path is /, which exactly matches "Home: /"
    assert_includes result, "[here:Home]"
    # First should be normal (not the current page)
    assert_includes result, "[normal:First]"
  end

  test "navigation tag renders selected state for child pages" do
    page = prepare_page_for_render(:child)

    content = %{<r:navigation paths="Home: / | Parent: /parent/">
      <r:normal>[normal:<r:title />]</r:normal>
      <r:here>[here:<r:title />]</r:here>
      <r:selected>[selected:<r:title />]</r:selected>
    </r:navigation>}

    page.parts.find_by(name: "body").update!(content: content)
    result = page.render_part(:body)

    # child page path is /parent/child/, which starts with /parent/
    assert_includes result, "[selected:Parent]"
  end

  test "navigation tag renders between content" do
    content = %{<r:navigation paths="Home: / | First: /first">
      <r:normal><r:title /></r:normal>
      <r:here><r:title /></r:here>
      <r:between> | </r:between>
    </r:navigation>}

    @page.parts.find_by(name: "body").update!(content: content)
    result = @page.render_part(:body)

    assert_includes result, " | "
  end

  test "navigation tag requires normal tag" do
    content = %{<r:navigation paths="Home: /">
      <r:here><r:title /></r:here>
    </r:navigation>}

    @page.parts.find_by(name: "body").update!(content: content)
    assert_raises(StandardTags::TagError, Radius::UndefinedTagError) do
      @page.render_part(:body)
    end
  end
end
