module Radiant
  class Exporter
    def self.export
      hash = {}
      [Radiant::Config, User, Page, PagePart, PageField, Snippet, Layout].each do |klass|
        hash[klass.name.pluralize] = klass.find(:all).inject({}) { |h, record| h[record.id.to_i] = record.attributes; h }
      end
      hash.to_yaml
    end
  end
end