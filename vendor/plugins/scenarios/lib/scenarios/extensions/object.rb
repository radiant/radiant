class Object
  def metaclass
    (class << self; self; end)
  end unless method_defined?(:metaclass)
end
