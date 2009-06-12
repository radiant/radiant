class BasicMetal
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/basic-metal/
      [200, {"Content-Type" => 'text/html'}, ['Extension with Metal!']]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end