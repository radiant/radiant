class EnvDumpPage < Page
  
  description %{
    Instead of rendering a page in the normal fashion the Env Dump
    behavior will output all of the environment variables on the
    request. This is occasionally useful for debugging.
  }
  
  def render
    %{<html><body><pre>#{ request.env.collect { |k,v| "#{k} => #{v}\n" } }</pre></body></html>}
  end
  
  def cache?
    false
  end

end