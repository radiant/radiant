require 'radiant/extension'

module Radiant
  class ExtensionLoader

    include Simpleton

    def initialize
    end

    def load_extensions
      core_extensions.each { |extension| load_extension(extension) }
      vendor_extensions.each { |extension| load_extension(extension) }
    end

private
    def core_extensions
      Dir["#{File.dirname(__FILE__)}/../../vendor/extensions/*/*_extension.rb"]
    end

    def vendor_extensions
      # TODO: Work out how the hell we do this when Radiant is installed as a gem
      Dir["#{File.dirname(__FILE__)}/../../../../vendor/extensions/*/*_extension.rb"]
    end

    def load_extension(extension_path)
      require extension_path
    end
  end
end
