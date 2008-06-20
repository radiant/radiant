class PeopleScenario < Scenario::Base
  
  def load
    create_person "John Long"
    create_person "Adam Williams"
  end
  
  helpers do
    def create_person(attributes = {})
      if attributes.kind_of?(String)
        first, last = attributes.split(/\s+/)
        attributes = { :first_name => first, :last_name => last }
      end 
      attributes = person_params(attributes)
      create_record(:person, attributes[:first_name].strip.gsub(' ', '_').underscore.to_sym, attributes)
    end
    
    def person_params(attributes = {})
      attributes = {
        :first_name => "John",
        :last_name  => "Q."
      }.update(attributes)
    end
  end
  
end