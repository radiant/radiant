describe "Radiant::ResourceResponses" do
  before :each do
    @klass = Class.new(ApplicationController)
    @klass.extend Radiant::ResourceResponses
  end
  
  describe "extending the controller" do
    it "should add the responses method" do
      expect(@klass).to respond_to(:responses)
    end
    
    it "should return a response collector" do
      expect(@klass.responses).to be_kind_of(Radiant::ResourceResponses::Collector)
    end
    
    it "should yield the collector to the passed block" do
      @klass.responses {|r| expect(r).to be_kind_of(Radiant::ResourceResponses::Collector) }
    end
    
    it "should add a response_for instance method" do
      expect(@klass.new).to respond_to(:response_for)
    end
    
    it "should add a wrap instance method" do
      expect(@klass.new).to respond_to(:wrap)
    end
    
    it "should duplicate on inheritance" do
      @subclass = Class.new(@klass)
      expect(@subclass.responses).not_to equal(@klass.responses)
    end
  end
  
  describe "responding to configured formats" do
    before :each do
      @default = lambda { render text: "Hello, world!" }
      @klass.responses do |r|
        r.plural.default(&@default)
      end
      @responder = double('responder')
      @instance = @klass.new
      allow(@instance).to receive(:respond_to).and_yield(@responder)
    end

    describe "when wrapping a block" do
      it "should evaluate the block in the context of the controller" do
        @instance.send(:instance_variable_set, "@foo", "foo")
        expect(@instance.wrap(Proc.new { @foo }).call).to eq('foo')
      end
    end
    
    it "should apply the default block to the :any format" do
      expect(@instance).to receive(:wrap).with(@default).and_return(@default)
      expect(@responder).to receive(:any).with(&@default)
      @instance.response_for(:plural)
    end
    
    it "should apply the publish block to the published formats before the default format" do
      @pblock = lambda { render text: 'bar' }
      @klass.responses[:plural].publish(:json, &@pblock)
      expect(@instance).to receive(:wrap).with(@pblock).twice.and_return(@pblock)
      expect(@instance).to receive(:wrap).with(@default).and_return(@default)
      expect(@responder).to receive(:json).with(&@pblock).once.ordered
      expect(@responder).to receive(:any).with(&@default).once.ordered
      @instance.response_for(:plural)
    end
    
    it "should apply custom formats before the published and default formats" do
      @iblock = lambda { render text: 'baz' }
      @pblock = lambda { render text: 'bar' }
      @klass.responses[:plural].iphone(&@iblock)
      expect(@instance).to receive(:wrap).with(@iblock).and_return(@iblock)
      expect(@instance).to receive(:wrap).with(@pblock).and_return(@pblock)
      expect(@instance).to receive(:wrap).with(@default).and_return(@default)
      expect(@responder).to receive(:iphone).with(&@iblock).once.ordered
      expect(@responder).to receive(:any).with(&@default).once.ordered
      @instance.response_for(:plural)
    end
    
    it "should apply the :any format when the default block is blank" do
      @klass.responses[:plural].send(:instance_variable_set, "@default", nil)
      expect(@responder).to receive(:any).with(no_args())
      @instance.response_for(:plural)
    end
    
    it "should apply a custom format when no block is given" do
      @klass.responses[:plural].iphone
      expect(@instance).to receive(:wrap).with(@default).and_return(@default)
      expect(@responder).to receive(:iphone)
      expect(@responder).to receive(:any)
      @instance.response_for(:plural)
    end
  end
end

describe Radiant::ResourceResponses::Collector do
  before :each do
    @collector = Radiant::ResourceResponses::Collector.new
  end
  
  it "should provide a Response object as the default property" do
    expect(@collector.plural).to be_kind_of(Radiant::ResourceResponses::Response)
  end
  
  it "should be duplicable" do
    expect(@collector).to be_duplicable
  end
  
  it "should duplicate its elements when duplicating" do
    @collector.plural.html
    @duplicate = @collector.dup
    expect(@collector.plural).not_to equal(@duplicate.plural)
  end
end

describe Radiant::ResourceResponses::Response do
  before :each do
    @response = Radiant::ResourceResponses::Response.new
  end
  
  it "should duplicate its elements when duplicating" do
    @response.default { render text: "foo" }
    @response.html
    @response.publish(:xml) { render }
    @duplicate = @response.dup
    expect(@response.blocks).not_to equal(@duplicate.blocks)
    expect(@response.default).not_to equal(@duplicate.default)
    expect(@response.publish_block).not_to equal(@duplicate.publish_block)
    expect(@response.publish_formats).not_to equal(@duplicate.publish_formats)
    expect(@response.block_order).not_to equal(@duplicate.block_order)
  end

  it "should accept a default response block" do
    @block = lambda { render text: 'foo' }
    @response.default(&@block)
    expect(@response.default).to eq(@block)
  end

  it "should accept a format symbol and block to publish" do
    @block = lambda { render xml: object }
    @response.publish(:xml, &@block) 
    expect(@response.publish_formats).to eq([:xml])
    expect(@response.publish_block).to eq(@block)
  end
  
  it "should require a publish block if one is not already assigned" do
    expect do
      @response.publish(:json)
    end.to raise_error
  end
  
  it "should accept multiple formats to publish" do
    @response.publish(:xml, :json) { render format_symbol => object }
    expect(@response.publish_formats).to eq([:xml, :json])
  end
  
  it "should add a new format to publish" do
    @response.publish(:xml) { render format_symbol => object }
    expect(@response.publish_formats).to eq([:xml])
    @response.publish(:json)
    expect(@response.publish_formats).to eq([:xml, :json])
  end
  
  it "should accept an arbitrary format block" do
    @block = lambda { render template: "foo" }
    @response.iphone(&@block) 
    expect(@response.blocks[:iphone]).to eq(@block)
  end

  it "should accept an arbitrary format without a block" do
    @response.iphone
    expect(@response.each_format).to eq([:iphone])
  end
  
  describe "prepared with some formats" do
    before :each do
      @responder = double("responder")
      @pblock = lambda { 'foo' }
      @response.publish(:xml, :json, &@pblock)
      @iblock = lambda { 'iphone' }
      @popblock = lambda { 'popup' }
      @response.iphone(&@iblock)
      @response.popup(&@popblock)
    end
    
    it "should iterate over the publish formats" do
      expect(@responder).to receive(:xml) {|a| a == @pblock}.once.ordered
      expect(@responder).to receive(:json) {|a| a == @pblock}.once.ordered
      @response.each_published do |format, block|
        @responder.send(format, &@block)
      end
    end

    it "should iterate over the regular formats" do
      expect(@responder).to receive(:iphone) {|a| a == @iblock}.once.ordered
      expect(@responder).to receive(:popup) {|a| a == @popblock}.once.ordered
      @response.each_format do |format, block|
        @responder.send(format, &@block)
      end
    end
  end
end