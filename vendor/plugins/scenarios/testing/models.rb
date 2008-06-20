class Person < ActiveRecord::Base; end
class Place < ActiveRecord::Base; end
class Thing < ActiveRecord::Base; end
class Note < ActiveRecord::Base; end

class SideEffectyThing < ActiveRecord::Base
  after_create do
    Thing.create!
  end
end

module ModelModule
  class Model < ActiveRecord::Base; end
end