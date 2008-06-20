class BlankScenario < Scenarios::Base
  def load
    table_names.each do |table|
      blast_table(table)
    end
  end

  def table_names
    self.class.table_names
  end

  def self.table_names
    @table_names ||= begin
      schema = (open(RAILS_ROOT + '/db/schema.rb') { |f| f.read } rescue '')
      schema.grep(/create_table\s+(['"])(.+?)\1/m) { $2 }
    end
  end
end
