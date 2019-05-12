module Dataset
  # An error raised when a dataset class cannot be found.
  #
  class DatasetNotFound < StandardError
  end
  
  # A dataset may be referenced as a class or as a name. A Dataset::Resolver
  # will take an identifier, whether a class or a name, and return the class.
  #
  class Resolver
    cattr_accessor :default
    
    def identifiers
      @identifiers ||= {}
    end
    
    # Attempt to convert a name to a constant. With the identifier :people, it
    # will search for 'PeopleDataset', then 'People'.
    #
    def resolve(identifier)
      return identifier if identifier.is_a?(Class)
      if constant = identifiers[identifier]
        return constant
      end

      constant = resolve_class(identifier)
      unless constant
        constant = resolve_identifier(identifier)
      end
      identifiers[identifier] = constant
    end
    
    protected
      def resolve_identifier(identifier) # :nodoc:
        constant = resolve_class(identifier)
        unless constant
          raise Dataset::DatasetNotFound, "Could not find a dataset '#{identifier.to_s.camelize}' or '#{identifier.to_s.camelize + suffix}'."
        end
        constant
      end
      
      def resolve_class(identifier)
        names = [identifier.to_s.camelize, identifier.to_s.camelize + suffix]
        constant = resolve_these(names.reverse)
        if constant && constant.superclass != ::Dataset::Base
          raise Dataset::DatasetNotFound, "Found a class '#{constant.name}', but it does not subclass 'Dataset::Base'."
        end
        constant
      end
      
      def resolve_these(names) # :nodoc:
        names.each do |name|
          constant = name.constantize rescue nil
          return constant if constant && constant.is_a?(Class)
        end
        nil
      end
      
      def suffix # :nodoc:
        @suffix ||= 'Dataset'
      end
  end
  
  # Resolves a dataset by looking for a file in the provided directory path
  # that has a name matching the identifier. Of course, should the identifier
  # be a class already, it is simply returned.
  #
  class DirectoryResolver < Resolver
    def initialize(*paths)
      @paths = paths
    end
    
    def <<(path)
      @paths << path
    end
    
    protected
      def resolve_identifier(identifier) # :nodoc:
        @paths.each do |path|
          file = File.join(path, identifier.to_s)
          unless File.exists?(file + '.rb')
            file = file + '_' + file_suffix
            next unless File.exists?(file + '.rb')
          end
          require file
          begin
            return super
          rescue Dataset::DatasetNotFound => dnf
            if dnf.message =~ /\ACould not find/
              raise Dataset::DatasetNotFound, "Found the dataset file '#{file + '.rb'}', but it did not define #{dnf.message.sub('Could not find ', '')}"
            else
              raise Dataset::DatasetNotFound, "Found the dataset file '#{file + '.rb'}' and a class #{dnf.message.sub('Found a class ', '')}"
            end
          end
        end
        raise DatasetNotFound, "Could not find a dataset file in #{@paths.inspect} having the name '#{identifier}.rb' or '#{identifier}_#{file_suffix}.rb'."
      end
      
      def file_suffix # :nodoc:
        @file_suffix ||= suffix.downcase
      end
  end
  
  # The default resolver, used by the Dataset::Sessions that aren't given a
  # different instance. You can set this to something else in your
  # test/spec_helper.
  #
  Resolver.default = Resolver.new
  
end