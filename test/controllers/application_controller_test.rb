require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "ApplicationController includes LoginSystem" do
    assert ApplicationController.included_modules.include?(LoginSystem)
  end

  test "ApplicationController responds to template_name" do
    controller = ApplicationController.new
    assert controller.respond_to?(:template_name)
  end

  {
    "index" => "index",
    "new" => "new",
    "create" => "new",
    "edit" => "edit",
    "update" => "edit",
    "show" => "show",
    "remove" => "remove",
    "destroy" => "remove",
    "custom" => "custom"
  }.each do |action, expected|
    test "template_name returns #{expected} for #{action} action" do
      controller = ApplicationController.new
      controller.define_singleton_method(:action_name) { action }
      assert_equal expected, controller.template_name
    end
  end
end
