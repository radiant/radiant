class PlacesScenario < Scenario::Base
  
  def load
    create_place "Taj Mahal", "India"
    create_place "Whitehouse", "Washington DC"
  end
  
  helpers do
    def create_place(name, location)
      attributes = place_params(:name => name, :location => location)
      create_record(:place, name.strip.gsub(' ', '_').underscore.to_sym, attributes)
    end
    
    def place_params(attributes = {})
      attributes = {
        :name => "Noplace",
        :location  => "Nowhere"
      }.update(attributes)
    end
  end
  
end