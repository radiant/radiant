(class << Dependencies; self; end).class_eval do
  def loadable_constants_for_path_with_filtered_args(*args)
    loadable_constants_for_path_without_filtered_args(*args).select {|path| /^(::)?([A-Z]\w*)(::[A-Z]\w*)*$/ =~ path }
  end
  alias_method_chain :loadable_constants_for_path, :filtered_args
end