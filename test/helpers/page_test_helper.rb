class NoCachePage < Page
  description 'Turns caching off for testing.'
  
  def cache?
    false
  end
end

unless defined?(CustomFileNotFoundPage)
  class CustomFileNotFoundPage < FileNotFoundPage
  end
end

class TestPage < Page
  description 'this is just a test page'
  
  tag 'test1' do
    'Hello world!'
  end
  
  tag 'test2' do
    'Another test.'
  end
  
  def headers
    {
      'cool' => 'beans',
      'request' => @request.inspect[20..30],
      'response' => @response.inspect[20..31]
    }
  end
  
end

class VirtualPage < Page
  def virtual?
    true
  end
end

module PageTestHelper
  
  VALID_PAGE_PARAMS = {
    :title => 'New Page',
    :slug => 'page',
    :breadcrumb => 'New Page',
    :status_id => '1',
    :parent_id => nil
  }
  
  def page_params(options = {})
    params = VALID_PAGE_PARAMS.dup
    params.merge!(:title => @page_title) if @page_title
    params.merge!(:status_id => '5')
    params.merge!(options)
  end
  
  def destroy_test_page(title = @page_title)
    while page = get_test_page(title) do
      page.destroy
    end
  end
  
  def get_test_page(title = @page_title)
    Page.find_by_title(title)
  end
  
  def create_test_page(options = {})
    options[:title] ||= @page_title
    klass = options.delete(:class_name) || Page
    klass = Kernel.eval(klass) if klass.kind_of? String
    page = klass.new page_params(options)
    if page.save
      page
    else
      raise "page <#{page.inspect}> could not be saved"
    end
  end
end
