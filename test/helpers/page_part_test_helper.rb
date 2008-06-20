module PagePartTestHelper
  VALID_PAGE_PART_PARAMS = {
    :name => 'custom',
    :content => 'Some simple content.',
    :page_id => '1'
  }
    
  def part_params(options = {})
    params = VALID_PAGE_PART_PARAMS.dup
    params.delete(:page_id)
    params.merge!(:name => @part_name) if @part_name
    params.merge!(options)
    params
  end
  
  def destroy_test_part(title = @part_name)
    while part = get_test_part(title) do
      part.destroy
    end
  end
  
  def get_test_part(name = @part_name)
    PagePart.find_by_name(name)
  end
  
  def create_test_part(name = @part_name)
    params = part_params
    params.merge!(:name => name)
    part = PagePart.new(params)
    if part.save
      part
    else
      raise "part <#{part.inspect}> could not be saved"
    end
  end
  
  # must be included after PageTestHelper to work
  def create_test_page(options = {})
    no_part = options.delete(:no_part)
    page = super(options)
    unless no_part
      part = PagePart.new part_params(:name => 'body', :content => 'test')
      page.parts << part
      page.save
      part.save
    end
    page
  end
end