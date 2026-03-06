require "test_helper"
require "method_observer"

class MethodObserverTest < ActiveSupport::TestCase
  test "observer has a target attribute" do
    observer = MethodObserver.new
    assert_respond_to observer, :target
    assert_nil observer.target
  end

  test "observer has a result accessor" do
    observer = MethodObserver.new
    assert_respond_to observer, :result
    assert_respond_to observer, :result=
  end

  test "observe sets the target" do
    observer = MethodObserver.new
    target = Object.new
    observer.observe(target)
    assert_equal target, observer.target
  end

  test "cannot observe twice raises error" do
    observer = MethodObserver.new
    target1 = Object.new
    target2 = Object.new
    observer.observe(target1)
    assert_raises(MethodObserver::ObserverCannotObserveTwiceError) do
      observer.observe(target2)
    end
  end

  test "ObserverCannotObserveTwiceError has default message" do
    error = MethodObserver::ObserverCannotObserveTwiceError.new
    assert_equal "observer cannot observe twice", error.message
  end

  test "tracks instances" do
    observer = MethodObserver.new
    assert_includes MethodObserver.instances.values, observer
  end
end
