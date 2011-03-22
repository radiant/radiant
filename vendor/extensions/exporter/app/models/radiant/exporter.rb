module Radiant
  class Exporter
    cattr_accessor :exportable_models
    @@exportable_models = [Radiant::Config, User, Page, PagePart, PageField, Snippet, Layout]
    cattr_accessor :template_models
    @@template_models = [Layout, Snippet, Page, PagePart, PageField]
    cattr_accessor :ignored_template_attributes
    @@ignored_template_attributes = [:lock_version, :created_at, :updated_at, :created_by_id, :updated_by_id]
    
    class << self
      def export(type='yaml')
        if self.respond_to?("export_#{type}")
          self.send("export_#{type}")
        else
          ''
        end
      end
      
      def export_yaml
        hash = ActiveSupport::OrderedHash.new
        @@exportable_models.each do |klass|
          hash[klass.name.pluralize] = klass.find(:all).inject(ActiveSupport::OrderedHash.new) { |h, record| h[record.id.to_i] = record.attributes; h }
        end
        hash.to_yaml
      end
      
      def export_template
        hash = ActiveSupport::OrderedHash.new
        hash['name'] = hash['description'] = "Exported Template #{Time.zone.now.to_i}"
        records = hash['records'] = ActiveSupport::OrderedHash.new
        @@template_models.each do |klass|
          records[klass.name.pluralize] = klass.find(:all).inject(ActiveSupport::OrderedHash.new) { |h, record|
            h[record.id.to_i] = record.attributes.delete_if{|att| @@ignored_template_attributes.include?(att[0].to_sym) };
            h
          }
        end
        hash.to_yaml
      end
    end
  end
end