class SiteController < ApplicationController
  skip_before_filter :verify_authenticity_token
  no_login_required
  cattr_writer :cache_timeout

  def self.cache_timeout
    @@cache_timeout ||= 5.minutes
  end
  
  def show_page
    url = params[:url]
    if Array === url
      url = url.join('/')
    else
      url = url.to_s
    end
    if @page = find_page(url)
      batch_page_status_refresh if (url == "/" || url == "")
      process_page(@page)
      set_cache_control
      @performed_render ||= true
    else
      render :template => 'site/not_found', :status => 404
    end
  rescue Page::MissingRootPageError
    redirect_to welcome_url
  end
  
  private
    def batch_page_status_refresh
      @changed_pages = []
      @pages = Page.find(:all, :conditions => {:status_id => 90})
      @pages.each do |page|
        if page.published_at <= Time.now
           page.status_id = 100
           page.save
           @changed_pages << page.id
        end
      end

      expires_in nil, :private=>true, "no-cache" => true if @changed_pages.length > 0      
    end
  
    def set_cache_control
      if (request.head? || request.get?) && @page.cache? && live?
        expires_in self.class.cache_timeout, :public => true, :private => false
      else
        expires_in nil, :private => true, "no-cache" => true
        headers['ETag'] = ''
      end
    end
        
    def find_page(url)
      found = Page.find_by_url(url, live?)
      found if found and (found.published? or dev?)
    end

    def process_page(page)
      page.pagination_parameters = pagination_parameters
      page.process(request, response)
   end

    def dev?
      if dev_host = @config['dev.host']
        request.host == dev_host
      else
        request.host =~ /^dev\./
      end
    end
    
    def live?
      not dev?
    end

end
