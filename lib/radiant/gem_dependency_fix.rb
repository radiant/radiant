require 'ruby-debug'
module Rails
  class GemDependency < Gem::Dependency
    def add_load_paths
      self.class.add_frozen_gem_path
      return if @loaded || @load_paths_added
      if framework_gem?
        @load_paths_added = @loaded = @frozen = true
        return
      end
      if self.requirement
        gem self.name, "#{self.requirement.requirements}"
      else
        gem self.name
      end
      @spec = Gem.loaded_specs[name]
      @frozen = @spec.loaded_from.include?(self.class.unpacked_path) if @spec
      @load_paths_added = true
    rescue Gem::LoadError
    end
  end
end