require "test_helper"

class Radiant::AdminUITest < ActiveSupport::TestCase
  setup do
    @admin_ui = Radiant::AdminUI.instance
  end

  test "AdminUI includes Simpleton" do
    assert_includes Radiant::AdminUI.ancestors, Simpleton
  end

  test "instance returns the same object" do
    assert_same Radiant::AdminUI.instance, Radiant::AdminUI.instance
  end

  test "has nav accessor" do
    assert_respond_to @admin_ui, :nav
  end

  test "nav_tab creates a NavTab" do
    tab = @admin_ui.nav_tab("Test")
    assert_instance_of Radiant::AdminUI::NavTab, tab
    assert_equal "Test", tab.name
  end

  test "nav_item creates a NavSubItem" do
    item = @admin_ui.nav_item("Test Item", "/test")
    assert_instance_of Radiant::AdminUI::NavSubItem, item
    assert_equal "Test Item", item.name
    assert_equal "/test", item.url
  end

  test "default nav includes Content tab" do
    assert @admin_ui.nav["Content"], "Content tab should exist"
    assert_instance_of Radiant::AdminUI::NavTab, @admin_ui.nav["Content"]
  end

  test "default nav includes Design tab" do
    assert @admin_ui.nav["Design"], "Design tab should exist"
  end

  test "default nav includes Settings tab" do
    assert @admin_ui.nav["Settings"], "Settings tab should exist"
  end

  test "Content tab has Pages sub-item" do
    content = @admin_ui.nav["Content"]
    pages_item = content["Pages"]
    assert pages_item, "Pages sub-item should exist"
    assert_equal "/admin/pages", pages_item.url
  end

  test "Settings tab has Users sub-item" do
    settings = @admin_ui.nav["Settings"]
    users_item = settings["Users"]
    assert users_item, "Users sub-item should exist"
    assert_equal "/admin/users", users_item.url
  end

  test "has page region set" do
    assert_respond_to @admin_ui, :page
    assert_respond_to @admin_ui, :pages
    assert_equal @admin_ui.page, @admin_ui.pages
  end

  test "has layout region set" do
    assert_respond_to @admin_ui, :layout
    assert_respond_to @admin_ui, :layouts
  end

  test "has user region set" do
    assert_respond_to @admin_ui, :user
    assert_respond_to @admin_ui, :users
  end

  test "has configuration region set" do
    assert_respond_to @admin_ui, :configuration
    assert_respond_to @admin_ui, :configurations
  end

  test "has extension region set" do
    assert_respond_to @admin_ui, :extension
    assert_respond_to @admin_ui, :extensions
  end

  test "page edit region has main partials" do
    edit = @admin_ui.page.edit
    assert_includes edit.main, "edit_header"
    assert_includes edit.main, "edit_form"
  end

  test "page index region has sitemap_head partials" do
    index = @admin_ui.page.index
    assert_includes index.sitemap_head, "title_column_header"
    assert_includes index.sitemap_head, "status_column_header"
  end

  test "layout edit region has form partials" do
    edit = @admin_ui.layout.edit
    assert_includes edit.form, "edit_title"
    assert_includes edit.form, "edit_content"
  end

  test "layout index region has thead partials" do
    index = @admin_ui.layout.index
    assert_includes index.thead, "title_header"
  end

  test "user edit region has form partials" do
    edit = @admin_ui.user.edit
    assert_includes edit.form, "edit_name"
    assert_includes edit.form, "edit_email"
    assert_includes edit.form, "edit_roles"
  end

  test "user index region has tbody partials" do
    index = @admin_ui.user.index
    assert_includes index.tbody, "title_cell"
    assert_includes index.tbody, "roles_cell"
  end

  test "extension index region has thead partials" do
    index = @admin_ui.extension.index
    assert_includes index.thead, "title_header"
    assert_includes index.thead, "version_header"
  end
end
