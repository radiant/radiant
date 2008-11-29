require File.dirname(__FILE__) + '/../spec_helper'
require File.join(File.dirname(__FILE__), *%w[.. .. lib autotest radiant_rails_rspec])
require File.join(File.dirname(__FILE__), *%w[.. matchers autotest_matchers])

describe Autotest::RadiantRailsRspec, "file mapping" do
  before(:each) do
    @autotest = Autotest::RadiantRailsRspec.new
    @autotest.hook :initialize
  end
  
  it "should map model example to model" do
    @autotest.should map_specs(['spec/models/thing_spec.rb']).
                            to('app/models/thing.rb')
  end
  
  it "should map controller example to controller" do
    @autotest.should map_specs(['spec/controllers/things_controller_spec.rb']).
                            to('app/controllers/things_controller.rb')
  end

  it "should map view.rhtml" do
    @autotest.should map_specs(['spec/views/things/index.rhtml_spec.rb']).
                            to('app/views/things/index.rhtml')
  end

  it "should map view.rhtml with underscores in example filename" do
    @autotest.should map_specs(['spec/views/things/index_rhtml_spec.rb']).
                            to('app/views/things/index.rhtml')
  end

  it "should map view.html.erb" do
    @autotest.should map_specs(['spec/views/things/index.html.erb_spec.rb']).
                            to('app/views/things/index.html.erb')
  end

  describe "with extensions" do
    it "should map model example to model" do
      @autotest.should map_specs(["#{ext_path}spec/models/thing_spec.rb"]).
                              to("#{ext_path}app/models/thing.rb")
    end

    it "should map controller example to controller" do
      @autotest.should map_specs(["#{ext_path}spec/controllers/things_controller_spec.rb"]).
                              to("#{ext_path}app/controllers/things_controller.rb")
    end

    it "should map nested controller example to nested controller" do
      @autotest.should map_specs(["#{ext_path}spec/controllers/nest/things_controller_spec.rb"]).
                              to("#{ext_path}app/controllers/nest/things_controller.rb")
    end

    it "should map view example to view" do
      @autotest.should map_specs(["#{ext_path}spec/views/things/index.html.erb_spec.rb"]).
                              to("#{ext_path}app/views/things/index.html.erb")
    end

    it "should map nested view example to nested view" do
      @autotest.should map_specs(["#{ext_path}spec/views/nest/things/index.html.erb_spec.rb"]).
                              to("#{ext_path}app/views/nest/things/index.html.erb")
    end

    it "should map helper example to helper" do
      @autotest.should map_specs(["#{ext_path}spec/helpers/thing_helper_spec.rb"]).
                              to("#{ext_path}app/helpers/thing_helper.rb")
    end

    it "should map nested helper example to nested helper" do
      @autotest.should map_specs(["#{ext_path}spec/helpers/nest/thing_helper_spec.rb"]).
                              to("#{ext_path}app/helpers/nest/thing_helper.rb")
    end

    it "should map lib example to lib" do
      @autotest.should map_specs(["#{ext_path}spec/lib/thing_spec.rb"]).
                              to("#{ext_path}lib/thing.rb")
    end
  end

  def ext_path
    'vendor/extensions/extension/'
  end
end