class BasicMetal
  def self.call(env)
    [200, {"Content-Type" => 'text/html'}, ['Extension with Metal!']]
  end
end