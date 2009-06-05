$: << File.dirname(__FILE__) + '/../lib'
require 'rubygems'
%w[spec action_pack active_record resourceful/maker
   action_controller action_controller/test_process action_controller/integration
   spec/rspec_on_rails/redirect_to spec/rspec_on_rails/render_template].each &method(:require)

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def should_be_called(&block)
  pstub = stub
  pstub.expects(:call).instance_eval(&(block || proc {}))
  proc { |*args| pstub.call(*args) }
end

def stub_model(name)
  model = Class.new do
    include Resourceful::Serialize::Model

    def self.to_s
      @name
    end

    def initialize(attrs = {})
      attrs.each do |k, v|
        self.stubs(k).returns(v)
      end
    end

    def inspect
      "#<#{self.class.send(:instance_variable_get, '@name')}>"
    end
  end
  model.send(:instance_variable_set, '@name', name)
  model
end

def stub_const(name)
  unless Object.const_defined?(name)
    obj = Object.new
    obj.metaclass.send(:define_method, :to_s) { name.to_s }
    obj.metaclass.send(:alias_method, :inspect, :to_s)
    Object.const_set(name, obj)
  end
  Object.const_get(name)
end

def stub_list(size, name = nil, &block)
  list = Array.new(size) { |i| name ? stub("#{name}_#{i}") : stub }
  list.each(&block) if block
  list
end

module Spec::Matchers
  def have_any(&proc)
    satisfy { |a| a.any?(&proc) }
  end
end

module ControllerMocks
  def mock_kontroller(*to_extend)
    options = to_extend.last.is_a?(Hash) ? to_extend.slice!(-1) : {}
    @kontroller = Class.new
    @kontroller.extend Resourceful::Maker
    to_extend.each(&@kontroller.method(:extend))

    @hidden_actions = Resourceful::ACTIONS.dup
    @kontroller.stubs(:hidden_actions).returns(@hidden_actions)
    @kontroller.stubs(:plural_action?).returns(false)
    @kontroller.stubs(:include)
    @kontroller.stubs(:before_filter)
    @kontroller.stubs(:helper_method)
  end

  def mock_controller(*to_extend)
    mock_kontroller
    @controller = @kontroller.new
    to_extend.each(&@controller.method(:extend))
  end

  def mock_builder(inherited = false)
    @builder = stub
    @builder.stubs(:response_for)
    @builder.stubs(:apply)
    @builder.stubs(:instance_eval).yields(@buildercc )
    @builder.stubs(:inherited?).returns(inherited)
    Resourceful::Base.stubs(:made_resourceful).returns([])
    Resourceful::Builder.stubs(:new).returns(@builder)
  end

  def create_builder
    @builder = Resourceful::Builder.new(@kontroller)
    class << @builder
      alias_method :made_resourceful, :instance_eval
    end    
  end

  def responses
    @kontroller.read_inheritable_attribute(:resourceful_responses)
  end

  def callbacks
    @kontroller.read_inheritable_attribute(:resourceful_callbacks)
  end

  def parents
    @kontroller.read_inheritable_attribute(:parents)
  end

  # Evaluates the made_resourceful block of mod (a module)
  # in the context of @builder.
  # @builder should be initialized via create_builder.
  def made_resourceful(mod)
    mod.included(@builder)
  end
end

module RailsMocks
  attr_reader :response, :request, :controller, :kontroller

  def included(mod)
    require 'ruby-debug'
    debugger
  end

  def mock_resourceful(options = {}, &block)
    options = {
      :name => "things"
    }.merge options

    init_kontroller options
    init_routes options

    stub_const(options[:name].singularize.camelize)
    kontroller.make_resourceful(&block)

    init_controller options
  end

  def assigns(name)
    controller.instance_variable_get("@#{name}")
  end

  def redirect_to(opts)
    RedirectTo.new(request, opts)
  end

  def render_template(path)
    RenderTemplate.new(path.to_s, @controller)
  end

  private

  def init_kontroller(options)
    @kontroller = Class.new ActionController::Base
    @kontroller.extend Resourceful::Maker

    @kontroller.metaclass.send(:define_method, :controller_name) { options[:name] }
    @kontroller.metaclass.send(:define_method, :controller_path) { options[:name] }
    @kontroller.metaclass.send(:define_method, :inspect) { "#{options[:name].camelize}Controller" }
    @kontroller.metaclass.send(:alias_method, :to_s, :inspect)

    @kontroller.send(:define_method, :controller_name) { options[:name] }
    @kontroller.send(:define_method, :controller_path) { options[:name] }
    @kontroller.send(:define_method, :inspect) { "#<#{options[:name].camelize}Controller>" }
    @kontroller.send(:alias_method, :to_s, :inspect)
    @kontroller.send(:include, ControllerMethods)

    @kontroller
  end

  def init_routes(options)
    ActionController::Routing::Routes.clear!
    route_block = options[:routes] || proc { |map| map.resources options[:name] }
    ActionController::Routing::Routes.draw(&route_block)
  end
  
  def init_controller(options)
    @controller = kontroller.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    @controller.request = @request
    @controller.response = @response
    @request.accept = '*/*'
    @request.env['HTTP_REFERER'] = 'http://test.host'

    @controller
  end

  def action_params(action, params = {})
    params.merge case action
                 when :show, :edit, :destroy: {:id => 12}
                 when :update: {:id => 12, :thing => {}}
                 when :create: {:thing => {}}
                 else {}
                 end
  end

  def action_method(action)
    method case action
           when :index, :show, :edit, :new: :get
           when :update: :put
           when :create: :post
           when :destroy: :delete
           end
  end

  module ControllerMethods
    def render(options=nil, deprecated_status=nil, &block)
      unless block_given?
        @template.metaclass.class_eval do
          define_method :file_exists? do true end
          define_method :render_file do |*args|
            @first_render ||= args[0]
          end
        end
      end

      super(options, deprecated_status, &block)
    end
  end
end

module Spec::Example::ExampleGroupMethods
  def should_render_html(action)
    it "should render HTML by default for #{action_string(action)}" do
      action_method(action)[action, action_params(action)]
      response.should be_success
      response.content_type.should == 'text/html'
    end
  end

  def should_render_js(action)
    it "should render JS for #{action_string(action)}" do
      action_method(action)[action, action_params(action, :format => 'js')]
      response.should be_success
      response.content_type.should == 'text/javascript'
    end
  end

  def shouldnt_render_xml(action)
    it "should render XML for #{action_string(action)}" do
      action_method(action)[action, action_params(action, :format => 'xml')]
      response.should_not be_success
      response.code.should == '406'
    end
  end

  def action_string(action)
    case action
    when :index:   "GET /things"
    when :show:    "GET /things/12"
    when :edit:    "GET /things/12/edit"
    when :update:  "PUT /things/12"
    when :create:  "POST /things"
    when :new:     "GET /things/new"
    when :destroy: "DELETE /things/12"
    end
  end
end

module Spec::Example
  class IntegrationExampleGroup < Test::Unit::TestCase
    include ExampleMethods
    class << self
      include ExampleGroupMethods
    end

    def initialize(defined_description, &implementation)
      super()
      @_defined_description = defined_description
      @_implementation = implementation
    end

    ExampleGroupFactory.register(:integration, self)
  end
end
