class Object
  def self.descendants
    subclasses_of(self)
  end
  def presence
    return self if present?
  end
end