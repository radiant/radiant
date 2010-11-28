##
#  Functions almost exactly like the standard Rails::Plugin::GemLocator,
#  but will not return gems that conform to Radiant extensions.
#  See radiant/extension_locator for the plugin locator that handles extensions.

module Radiant
  class GemLocator < Rails::Plugin::GemLocator
    def plugins
      gem_index = initializer.configuration.gems.inject({}) { |memo, gem| memo.update gem.specification => gem }
      specs     = gem_index.keys
      specs    += Gem.loaded_specs.values.select do |spec|
        spec.loaded_from && # prune stubs
          File.exist?(File.join(spec.full_gem_path, "rails", "init.rb"))
      end
      specs.compact!
      specs.reject! { |s| s.name =~ /^radiant-.*-extension$/ }

      require "rubygems/dependency_list"

      deps = Gem::DependencyList.new
      deps.add(*specs) unless specs.empty?

      deps.dependency_order.collect do |spec|
        Rails::GemPlugin.new(spec, gem_index[spec])
      end
    end
  end
end