require 'spec_helper'

# http://blog.davidchelimsky.net/articles/2007/06/03/oxymoron-testing-behaviour-of-abstractions
describe Radiant::ApplicationController do

  it 'should include LoginSystem' do
    expect(Radiant::ApplicationController.included_modules).to include(LoginSystem)
  end

  it 'should initialize detail' do
    expect(controller.detail).to eq(Radiant::Config)
  end

  it 'should initialize the javascript and stylesheets arrays' do
      expect(Radiant::ApplicationController._process_action_callbacks.find(:set_javascripts_and_stylesheets)).not_to be_nil
    controller.send :set_javascripts_and_stylesheets
    expect(controller.send(:instance_variable_get, :@javascripts)).not_to be_nil
    expect(controller.send(:instance_variable_get, :@javascripts)).to be_instance_of(Array)
    expect(controller.send(:instance_variable_get, :@stylesheets)).not_to be_nil
    expect(controller.send(:instance_variable_get, :@stylesheets)).to be_instance_of(Array)
  end

  it "should include stylesheets" do
    controller.send :set_javascripts_and_stylesheets
    expect(controller.include_stylesheet('test')).to include('test')
  end

  it "should include javascripts" do
    controller.send :set_javascripts_and_stylesheets
    expect(controller.include_javascript('test')).to include('test')
  end

  describe 'self.template_name' do
    it "should return 'index' when the controller action_name is 'index'" do
      allow(controller).to receive(:action_name).and_return('index')
      expect(controller.template_name).to eq('index')
    end
    ['new', 'create'].each do |action|
      it "should return 'new' when the action_name is #{action}" do
      allow(controller).to receive(:action_name).and_return(action)
      expect(controller.template_name).to eq('new')
      end
    end
    ['edit', 'update'].each do |action|
      it "should return 'edit' when the action_name is #{action}" do
      allow(controller).to receive(:action_name).and_return(action)
      expect(controller.template_name).to eq('edit')
      end
    end
    ['remove', 'destroy'].each do |action|
      it "should return 'remove' when the action_name is #{action}" do
      allow(controller).to receive(:action_name).and_return(action)
      expect(controller.template_name).to eq('remove')
      end
    end
    it "should return 'show' when the action_name is show" do
      allow(controller).to receive(:action_name).and_return('show')
      expect(controller.template_name).to eq('show')
    end
    it "should return the action_name when the action_name is a non-standard name" do
      allow(controller).to receive(:action_name).and_return('other')
      expect(controller.template_name).to eq('other')
    end
  end

  describe "set_timezone" do
    it "should use Radiant::Config['local.timezone']" do
      Radiant::Config['local.timezone'] = 'Kuala Lumpur'
      controller.send(:set_timezone)
      expect(Time.zone.name).to eq('Kuala Lumpur')
    end

    it "should default to config.time_zone" do
      Radiant::Config.initialize_cache # to clear out setting from previous tests
      controller.send(:set_timezone)
      expect(Time.zone.name).to eq('UTC')
    end
  end
end
