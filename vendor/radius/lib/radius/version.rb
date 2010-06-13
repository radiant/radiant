module Radius #:nodoc:
  def self.version
    @version ||= begin
      filename = File.join(File.dirname(__FILE__), '..', '..', 'VERSION')
      IO.read(filename).strip
    end
  end
end