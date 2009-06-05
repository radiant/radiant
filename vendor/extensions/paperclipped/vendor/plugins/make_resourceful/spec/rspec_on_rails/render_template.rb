
class RenderTemplate
  
  def initialize(expected, controller)
    @controller = controller
    @expected = expected
  end
  
  def matches?(response)
    @actual = response.rendered_file
    full_path(@actual) == full_path(@expected)
  end

  def failure_message
    "expected #{@expected.inspect}, got #{@actual.inspect}"
  end
  
  def description
    "render template #{@expected.inspect}"
  end
  
  private
  def full_path(path)
    return nil if path.nil?
    path.include?('/') ? path : "#{@controller.class.to_s.underscore.gsub('_controller','')}/#{path}"
  end
  
end
