require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dataset::SessionBinding do
  before :all do
    @database = Dataset::Database::Sqlite3.new({:database => SQLITE_DATABASE}, "#{SPEC_ROOT}/tmp")
  end
  
  before do
    @database.clear
    @binding = Dataset::SessionBinding.new(@database)
  end
  
  it 'should support direct record inserts like classic fixtures' do
    Thing.should_not_receive :new
    lambda do
      return_value = @binding.create_record Thing
      return_value.should be_kind_of(Integer)
    end.should change(Thing, :count).by(1)
  end
  
  it 'should support creating records by instantiating the record class so callbacks work' do
    thing = Thing.new
    Thing.should_receive(:new).and_return(thing)
    lambda do
      return_value = @binding.create_model Thing
      return_value.should be_kind_of(Thing)
    end.should change(Thing, :count).by(1)
  end
  
  it 'should provide itself to the instance loaders' do
    anything = Object.new
    anything.extend @binding.model_finders
    anything.dataset_session_binding.should == @binding
  end
  
  describe 'create_record' do
    it 'should accept raw attributes for the insert' do
      @binding.create_record Thing, :name => 'my thing'
      Thing.last.name.should == 'my thing'
    end
    
    it 'should optionally accept a symbolic name for later lookup' do
      id = @binding.create_record Thing, :my_thing, :name => 'my thing'
      @binding.find_model(Thing, :my_thing).id.should == id
      @binding.find_id(Thing, :my_thing).should == id
    end
    
    it 'should auto-assign _at and _on columns with their respective time types' do
      @binding.create_record Note
      Note.last.created_at.should_not be_nil
      Note.last.updated_at.should_not be_nil
      
      @binding.create_record Thing
      Thing.last.created_on.should_not be_nil
      Thing.last.updated_on.should_not be_nil
    end
    
    it 'should support belongs_to associations using symbolic name of associated type' do
      person_id = @binding.create_record Person, :person
      @binding.create_record Note, :note, :person => :person
      Note.last.person_id.should == person_id
    end
  end
  
  describe 'create_model' do
    it 'should accept raw attributes for the insert' do
      @binding.create_model Thing, :name => 'my thing'
      Thing.last.name.should == 'my thing'
    end
    
    it 'should optionally accept a symbolic name for later lookup' do
      thing = @binding.create_model Thing, :my_thing, :name => 'my thing'
      @binding.find_model(Thing, :my_thing).should == thing
      @binding.find_id(Thing, :my_thing).should == thing.id
    end
    
    it 'should bypass mass assignment restrictions' do
      person = @binding.create_model Person, :first_name => 'Adam', :last_name => 'Williams'
      person.last_name.should == 'Williams'
    end
    
    
    it 'should support belongs_to associations using symbolic name of associated type' do
      person_id = @binding.create_record Person, :person
      @binding.create_model Note, :note, :person => :person
      Note.last.person_id.should == person_id
    end
  end
  
  describe 'model finders' do
    before do
      @context = Object.new
      @context.extend @binding.model_finders
      @note_one = @binding.create_model Note, :note_one
    end
    
    it 'should not exist for types that have not been created' do
      lambda do
        @context.things(:whatever)
      end.should raise_error(NoMethodError)
    end
    
    it 'should exist for the base classes of created types' do
      @binding.create_record State, :state_one
      @context.places(:state_one).should_not be_nil
      @context.places(:state_one).should == @context.states(:state_one)
    end
    
    it 'should exist for all ancestors' do
      @binding.create_record NorthCarolina, :nc
      @context.states(:nc).should == @context.north_carolinas(:nc)
    end
    
    it 'should exist for types made with create_model' do
      @context.notes(:note_one).should == @note_one
      @context.note_id(:note_one).should == @note_one.id
    end
    
    it 'should exist for types made with create_record' do
      id = @binding.create_record Note, :note_two
      @context.notes(:note_two).id.should == id
      @context.note_id(:note_two).should == id
    end
    
    it 'should exist for types registered with name_model' do
      thing = Thing.create!
      @binding.name_model(thing, :thingy)
      @context.things(:thingy).should == thing
    end
    
    it 'should support multiple names, returning an array' do
      note_two = @binding.create_model Note, :note_two
      @context.notes(:note_one, :note_two).should == [@note_one, note_two]
      @context.note_id(:note_one, :note_two).should == [@note_one.id, note_two.id]
    end
    
    it 'should support models inside modules' do
      @binding.create_record Nested::Place, :myplace, :name => 'Home'
      @context.nested_places(:myplace).name.should == 'Home'
    end
  end
  
  describe 'name_model' do
    before do
      @state = State.create!(:name => 'NC')
      @binding.name_model(@state, :mystate)
    end
    
    it 'should allow assigning a name to a model for later lookup' do
      @binding.find_model(State, :mystate).should == @state
    end
    
    it 'should allow finding STI' do
      @context = Object.new
      @context.extend @binding.model_finders
      @context.places(:mystate).should == @state
    end
  end
  
  describe 'name_to_sym' do
    it 'should convert strings to symbols' do
      @binding.name_to_sym(nil).should == nil
      @binding.name_to_sym('thing').should == :thing
      @binding.name_to_sym('Mything').should == :mything
      @binding.name_to_sym('MyThing').should == :my_thing
      @binding.name_to_sym('My Thing').should == :my_thing
      @binding.name_to_sym('"My Thing"').should == :my_thing
      @binding.name_to_sym('\'My Thing\'').should == :my_thing
    end
  end
  
  describe 'nested bindings' do
    before do
      @binding.create_model Thing, :mything, :name => 'my thing'
      @nested_binding = Dataset::SessionBinding.new(@binding)
    end
    
    it 'should walk up the tree to find models' do
      @nested_binding.find_model(Thing, :mything).should == @binding.find_model(Thing, :mything)
    end
    
    it 'should raise an error if an object cannot be found for a name' do
      lambda do
        @nested_binding.find_model(Thing, :yourthing)
      end.should raise_error(Dataset::RecordNotFound, "There is no 'Thing' found for the symbolic name ':yourthing'.")
      
      lambda do
        @nested_binding.find_id(Thing, :yourthing)
      end.should raise_error(Dataset::RecordNotFound, "There is no 'Thing' found for the symbolic name ':yourthing'.")
    end
    
    it 'should have instance loader methods from parent binding' do
      anything = Object.new
      anything.extend @nested_binding.model_finders
      anything.things(:mything).should_not be_nil
    end
  end
end