module Radiant
  class Exporter
    cattr_accessor :exportable_models
    @@exportable_models = [Radiant::Config, User, Page, PagePart, PageField, Snippet, Layout]
    
    def self.export
      hash = {}
      @@exportable_models.each do |klass|
        hash[klass.name.pluralize] = klass.find(:all).inject({}) { |h, record| h[record.id.to_i] = record.attributes; h }
      end
      hash.to_yaml
    end
  end
end