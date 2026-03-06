require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "ApplicationController includes LoginSystem" do
    assert ApplicationController.included_modules.include?(LoginSystem)
  end

  test "ApplicationController responds to template_name" do
    controller = ApplicationController.new
    assert controller.respond_to?(:template_name)
  end

  test "template_name returns index for index action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "index" }
    assert_equal "index", controller.template_name
  end

  test "template_name returns new for new action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "new" }
    assert_equal "new", controller.template_name
  end

  test "template_name returns new for create action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "create" }
    assert_equal "new", controller.template_name
  end

  test "template_name returns edit for edit action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "edit" }
    assert_equal "edit", controller.template_name
  end

  test "template_name returns edit for update action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "update" }
    assert_equal "edit", controller.template_name
  end

  test "template_name returns show for show action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "show" }
    assert_equal "show", controller.template_name
  end

  test "template_name returns remove for remove action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "remove" }
    assert_equal "remove", controller.template_name
  end

  test "template_name returns remove for destroy action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "destroy" }
    assert_equal "remove", controller.template_name
  end

  test "template_name returns action_name for unknown action" do
    controller = ApplicationController.new
    controller.define_singleton_method(:action_name) { "custom" }
    assert_equal "custom", controller.template_name
  end
end
