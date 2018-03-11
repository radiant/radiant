describe "Radiant::Config::Definition" do
  before :each do
    Radiant::Config.initialize_cache
    @basic = Radiant::Config::Definition.new({
      default: 'quite testy'
    })
    @boolean = Radiant::Config::Definition.new({
      type: :boolean,
      default: true
    })
    @integer = Radiant::Config::Definition.new({
      type: :integer,
      default: 50
    })
    @validating = Radiant::Config::Definition.new({
      default: "Monkey",
      validate_with: lambda {|s| s.errors.add(:value, "That's no monkey") unless s.value == "Monkey" }
    })
    @selecting = Radiant::Config::Definition.new({
      default: "Monkey",
      select_from: [["m", "Monkey"], ["g", "Goat"]]
    })
    @selecting_from_hash = Radiant::Config::Definition.new({
      default: "Non-monkey",
      allow_blank: true,
      select_from: {"monkey" => "Definitely a monkey", "goat" => "No fingers", "Bear" => "Angry, huge", "Donkey" => "Non-monkey"}
    })
    @selecting_required = Radiant::Config::Definition.new({
      default: "other",
      allow_blank: false,
      select_from: lambda { ['recent', 'other', 'misc'] }
    })
    @enclosed = "something"
    @selecting_at_runtime = Radiant::Config::Definition.new({
      default: "something",
      select_from: lambda { [@enclosed] }
    })
    @protected = Radiant::Config::Definition.new({
      default: "Monkey",
      allow_change: false
    })
    @hiding = Radiant::Config::Definition.new({
      default: "Secret Monkey",
      allow_display: false
    })
    @present = Radiant::Config::Definition.new({
      default: "Hola",
      allow_blank: false
    })
  end
  after :each do
    Radiant::Cache.clear if defined? Radiant::Cache
    Radiant.detail.clear_definitions!
  end

  describe "basic definition" do
    before do
      Radiant.detail.define('test', @basic)
      @setting = Radiant::Config.find_by_key('test')
    end

    it "should specify a default" do
      expect(@basic.default).to eq("quite testy")
      expect(@setting.value).to eq("quite testy")
      expect(Radiant::Config['test']).to eq('quite testy')
    end
  end

  describe "validating" do
    before do
      Radiant::Config.define('valid', @validating)
      Radiant::Config.define('number', @integer)
      Radiant::Config.define('selecting', @selecting)
      Radiant::Config.define('required', @present)
    end

    it "should validate against the supplied block" do
      setting = Radiant::Config.find_by_key('valid')
      expect{setting.value = "Ape"}.to raise_error(ActiveRecord::RecordInvalid)
      expect(setting.valid?).to be false
      expect(setting.errors[:value]).to include("That's no monkey")
    end

    it "should allow a valid value to be set" do
      expect{Radiant::Config['valid'] = "Monkey"}.not_to raise_error
      expect(Radiant::Config['valid']).to eq("Monkey")
      expect{Radiant::Config['selecting'] = "Goat"}.not_to raise_error
      expect{Radiant::Config['selecting'] = ""}.not_to raise_error
      expect{Radiant::Config['integer'] = "27"}.not_to raise_error
      expect{Radiant::Config['integer'] = 27}.not_to raise_error
      expect{Radiant::Config['required'] = "Still here"}.not_to raise_error
    end

    it "should not allow an invalid value to be set" do
      expect{Radiant::Config['valid'] = "Cow"}.to raise_error(ActiveRecord::RecordInvalid)
      expect(Radiant::Config['valid']).not_to eq("Cow")
      expect{Radiant::Config['selecting'] = "Pig"}.to raise_error(ActiveRecord::RecordInvalid)
      expect{Radiant::Config['number'] = "Pig"}.to raise_error(ActiveRecord::RecordInvalid)
      expect{Radiant::Config['required'] = ""}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "offering selections" do
    before do
      Radiant::Config.define('not', @basic)
      Radiant::Config.define('now', @selecting)
      Radiant::Config.define('hashed', @selecting_from_hash)
      Radiant::Config.define('later', @selecting_at_runtime)
      Radiant::Config.define('required', @selecting_required)
    end

    it "should identify itself as a selector" do
      expect(Radiant::Config.find_by_key('not').selector?).to be false
      expect(Radiant::Config.find_by_key('now').selector?).to be true
    end

    it "should offer a list of options" do
      expect(Radiant::Config.find_by_key('required').selection.size).to eq(3)
      expect(Radiant::Config.find_by_key('now').selection.include?(["", ""])).to be true
      expect(Radiant::Config.find_by_key('now').selection.include?(["m", "Monkey"])).to be true
      expect(Radiant::Config.find_by_key('now').selection.include?(["g", "Goat"])).to be true
    end

    it "should run a supplied selection block" do
      @enclosed = "testing"
      expect(Radiant::Config.find_by_key('later').selection.include?(["testing", "testing"])).to be true
    end

    it "should normalise the options to a list of pairs" do
      expect(Radiant::Config.find_by_key('hashed').selection.is_a?(Hash)).to be false
      expect(Radiant::Config.find_by_key('hashed').selection.include?(["monkey", "Definitely a monkey"])).to be true
    end

    it "should not include a blank option if allow_blank is false" do
      expect(Radiant::Config.find_by_key('required').selection.size).to eq(3)
      expect(Radiant::Config.find_by_key('required').selection.include?(["", ""])).to be false
    end

  end

  describe "protecting" do
    before do
      Radiant::Config.define('required', @present)
      Radiant::Config.define('fixed', @protected)
    end

    it "should raise a ConfigError when a protected value is set" do
      expect{ Radiant::Config['fixed'] = "different" }.to raise_error(Radiant::Config::ConfigError)
    end

    it "should raise a validation error when a required value is made blank" do
      expect{ Radiant::Config['required'] = "" }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end


end

