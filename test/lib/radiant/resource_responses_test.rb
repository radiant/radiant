require "test_helper"

class Radiant::ResourceResponsesTest < ActiveSupport::TestCase
  def setup_test_class
    Class.new do
      extend Radiant::ResourceResponses
    end
  end

  test "can define responses on a class" do
    klass = setup_test_class
    assert_respond_to klass, :responses
  end

  test "responses returns a Collector" do
    klass = setup_test_class
    assert_instance_of Radiant::ResourceResponses::Collector, klass.responses
  end

  test "responses yields the collector when given a block" do
    klass = setup_test_class
    yielded = nil
    klass.responses do |r|
      yielded = r
    end
    assert_instance_of Radiant::ResourceResponses::Collector, yielded
  end

  test "collector creates Response objects for unknown methods" do
    klass = setup_test_class
    response = klass.responses.index
    assert_instance_of Radiant::ResourceResponses::Response, response
  end

  test "response for different actions returns separate Response objects" do
    klass = setup_test_class
    index_response = klass.responses.index
    show_response = klass.responses.show
    refute_same index_response, show_response
  end

  test "Response tracks block_order for formats" do
    response = Radiant::ResourceResponses::Response.new
    response.html { "html response" }
    response.json { "json response" }
    assert_equal [:html, :json], response.block_order
  end

  test "Response default stores a block" do
    response = Radiant::ResourceResponses::Response.new
    assert_nil response.default
    response.default { "fallback" }
    assert_not_nil response.default
  end

  test "Response publish adds formats" do
    response = Radiant::ResourceResponses::Response.new
    response.publish(:rss, :atom) { "published" }
    assert_equal [:rss, :atom], response.publish_formats
  end

  test "including class gets response_for instance method" do
    klass = setup_test_class
    assert klass.method_defined?(:response_for),
      "Expected response_for to be defined as an instance method"
  end
end
