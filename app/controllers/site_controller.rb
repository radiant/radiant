class SiteController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  no_login_required
  
  def show_page
    url = params[:url]
    if Array === url
      url = url.join('/')
    else
      url = url.to_s
    end
    
    @page = find_page(url)
    unless @page.nil?
      process_page(@page)
      @performed_render = true
    else
      render :template => 'site/not_found', :status => 404
    end
  rescue Page::MissingRootPageError
    redirect_to welcome_url
  end
  
  private
    
    def find_page(url)
      found = Page.find_by_url(url, live?)
      found if found and (found.published? or dev?)
    end

    def process_page(page)
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
