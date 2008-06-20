module LayoutTestHelper
  
  VALID_LAYOUT_PARAMS = {
   :name => 'Test Layout',
   :content => 'Just a test.'
  }

  def layout_params(options = {})
    params = VALID_LAYOUT_PARAMS.dup
    params.merge!(:name => @layout_name) if @layout_name
    params.merge!(options)
  end

  def destroy_test_layout(name = @layout_name)
    while layout = get_test_layout(name) do
      layout.destroy
    end
  end
  
  def get_test_layout(name = @layout_name)
    Layout.find_by_name(name)
  end
  
  def create_test_layout(name = @layout_name)
    params = layout_params
    params.merge!(:name => name) if name
    layout = Layout.new(params)
    if layout.save
      layout
    else
      raise "layout <#{layout.inspect}> could not be saved"
    end
  end
  
end