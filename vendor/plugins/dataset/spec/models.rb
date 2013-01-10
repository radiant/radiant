class Person < ActiveRecord::Base
  attr_protected :last_name
end
class Place < ActiveRecord::Base
  self.table_name = 'places_table'
end
class Thing < ActiveRecord::Base; end
class Note < ActiveRecord::Base
  belongs_to :person
end
class State < Place; end
class NorthCarolina < State; end

module Nested
  class Place < ActiveRecord::Base
    self.table_name = 'places_table'
  end
end
