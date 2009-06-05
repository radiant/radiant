require 'resourceful/builder'

module Resourceful
  # This module contains mixin modules
  # used to implement the object serialization
  # used for the Builder#publish method.
  # They can also be used to get serialized representations of objects
  # in other contexts.
  #
  # Serialization makes use of duck typing.
  # Each class that can be serialized
  # (just Array and ActiveRecord::Base by default)
  # implements the +serialize+ and +to_serializable+ methods.
  # These methods are implemented differently by the different classes,
  # but the semantics of the implementations are consistent,
  # so they can be used consistently.
  #
  # +to_serializable+ returns an object that can be directly serialized
  # with a call to +to_xml+, +to_yaml+, or +to_json+.
  # This object is either a hash or an array,
  # and all the elements are either values, like strings and integers,
  # or other serializable objects.
  # This is useful for getting a model into a simple data structure format.
  # The +attributes+ argument uses the same semantics
  # as the <tt>:attributes</tt> option for Builder#publish.
  # For example:
  #
  #   c = Cake.new(:flavor => 'chocolate', :text => 'Happy birthday, Chris!')
  #   c.recipient = User.new(:name => 'Chris', :password => 'not very secure')
  #   c.to_serializable [
  #       :flavor, :text,
  #       :recipient => :name
  #     ]
  #
  # This would return the Ruby hash
  #
  #   { :flavor => 'chocolate', :text => 'Happy birthday, Chris!',
  #     :user => {:name => 'Chris'} }
  #
  # +serialize+ takes a format (<tt>:xml</tt>, <tt>:yaml</tt>, or <tt>:json</tt> - see New Formats below)
  # and a hash of options.
  # The only option currently recognized is <tt>:attributes</tt>,
  # which has the same semantics
  # as the <tt>:attributes</tt> option for Builder#publish.
  # +serialize+ returns a string containing the target
  # serialized in the given format.
  # For example:
  #
  #   c = CandyBag.new(:title => 'jellybag')
  #   c.candies << Candy.new(:type => 'jellybean', :flavor => 'root beer')
  #   c.candies << Candy.new(:type => 'jellybean', :flavor => 'pear')
  #   c.candies << Candy.new(:type => 'licorice',  :flavor => 'anisey')
  #   c.serialize :xml, :attributes => [:title, {:candies => [:type, :flavor]}]
  #
  # This would return a Ruby string containing
  #
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <candy-bag>
  #     <title>jellybag</title>
  #     <candies>
  #       <candy>
  #         <type>jellybean</type>
  #         <flavor>root beer</flavor>
  #       </candy>
  #       <candy>
  #         <type>jellybean</type>
  #         <flavor>pear</flavor>
  #       </candy>
  #       <candy>
  #         <type>licorice</type>
  #         <flavor>anisey</flavor>
  #       </candy>
  #     </candies>
  #   </candy-bag>
  # 
  module Serialize

    # Takes an attributes option in the form passed to Builder#publish
    # and returns a hash (or nil, if attributes is nil)
    # containing the same data,
    # but in a more consistent format.
    # All keys are converted to symbols,
    # and all lists are converted to hashes.
    # For example:
    #
    #   Resourceful::Serialize.normalize_attributes([:foo, :bar, {"baz" => ["boom"]}])
    #     #=> {"baz"=>["boom"], :foo=>nil, :bar=>nil}
    # 
    def self.normalize_attributes(attributes) # :nodoc:
      return nil if attributes.nil?
      return {attributes.to_sym => nil} if String === attributes
      return {attributes => nil} if !attributes.respond_to?(:inject)

      attributes.inject({}) do |hash, attr|
        if Array === attr
          hash[attr[0]] = attr[1]
          hash
        else
          hash.merge normalize_attributes(attr)
        end
      end
    end

    # This module contains the definitions of +serialize+ and +to_serializable+
    # that are included in ActiveRecord::Base.
    module Model
      # :call-seq:
      #   serialize format, options = {}, :attributes => [ ... ]
      #
      # See the module documentation for Serialize for details.
      def serialize(format, options)
        raise "Must specify :attributes option" unless options[:attributes]
        hash = self.to_serializable(options[:attributes])
        root = self.class.to_s.underscore
        if format == :xml
          hash.send("to_#{format}", :root => root)
        else
          {root => hash}.send("to_#{format}")
        end
      end

      # See the module documentation for Serialize for details.
      def to_serializable(attributes)
        raise "Must specify attributes for #{self.inspect}.to_serializable" if attributes.nil?

        Serialize.normalize_attributes(attributes).inject({}) do |hash, (key, value)|
          hash[key.to_s] = attr_hash_value(self.send(key), value)
          hash
        end
      end

      private

      # Given an attribute value
      # and a normalized (see above) attribute hash,
      # returns the serializable form of that attribute.
      def attr_hash_value(attr, sub_attributes)
        if attr.respond_to?(:to_serializable)
          attr.to_serializable(sub_attributes)
        else
          attr
        end
      end
    end

    # This module contains the definitions of +serialize+ and +to_serializable+
    # that are included in ActiveRecord::Base.
    module Array
      # :call-seq:
      #   serialize format, options = {}, :attributes => [ ... ]
      #
      # See the module documentation for Serialize for details.      
      def serialize(format, options)
        raise "Not all elements respond to to_serializable" unless all? { |e| e.respond_to? :to_serializable }
        raise "Must specify :attributes option" unless options[:attributes]

        serialized = map { |e| e.to_serializable(options[:attributes]) }
        root = first.class.to_s.pluralize.underscore

        if format == :xml
          serialized.send("to_#{format}", :root => root)
        else
          {root => serialized}.send("to_#{format}")
        end
      end

      # See the module documentation for Serialize for details.
      def to_serializable(attributes)
        if first.respond_to?(:to_serializable)
          attributes = Serialize.normalize_attributes(attributes)
          map { |e| e.to_serializable(attributes) }
        else
          self
        end
      end
    end
  end
end

class ActiveRecord::Base; include Resourceful::Serialize::Model; end
class Array; include Resourceful::Serialize::Array; end
