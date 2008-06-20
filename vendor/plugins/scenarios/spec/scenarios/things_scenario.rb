class ThingsScenario < Scenario::Base

  def load
    create_thing "one"
    create_thing "two"
  end

  helpers do
    def create_thing(attributes = {})
      attributes = { :name => attributes } if attributes.kind_of?(String)
      attributes = thing_params(attributes)
      create_record(:thing, attributes[:name].strip.gsub(' ', '_').underscore.to_sym, attributes)
    end

    def thing_params(attributes = {})
      attributes = {
        :name        => "Unnamed Thing",
        :description => "I'm not sure what this is."
      }.update(attributes)
    end
  end
end
