require 'radiant/pagination/controller'

module Radiant
  class SiteController < Radiant::ApplicationController
    include Radiant::Pagination::Controller

    skip_before_filter :verify_authenticity_token

    def self.cache_timeout=(val)
      Radiant::PageResponseCacheDirector.cache_timeout=(val)
    end
    def self.cache_timeout
      Radiant::PageResponseCacheDirector.cache_timeout
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
        render template: 'radiant/site/not_found', status: 404
      end
    rescue Page::MissingRootPageError
      redirect_to welcome_url
    end

    def cacheable_request?
      (request.head? || request.get?) && live?
    end
    hide_action :cacheable_request?

    def set_expiry(time, options={})
      expires_in time, options
    end
    hide_action :set_expiry

    def set_etag(val)
      headers['ETag'] = val
    end
    hide_action :set_expiry

    private
      def batch_page_status_refresh
        @changed_pages = []
        @pages = Page.all.where(status_id: Status[:scheduled].id)
        @pages.each do |page|
          if page.published_at <= Time.now
             page.status_id = Status[:published].id
             page.save
             @changed_pages << page.id
          end
        end

        expires_in nil, private:true, "no-cache" => true if @changed_pages.length > 0
      end

      def set_cache_control
        response_cache_director(@page).set_cache_control
      end

      def response_cache_director(page)
        klass_name = "Radiant::#{page.class}ResponseCacheDirector"
        begin
          klass = klass_name.constantize
        rescue NameError, LoadError
          director_klass = "Radiant::PageResponseCacheDirector"
          eval(%Q{class #{klass_name} < #{director_klass}; end}, TOPLEVEL_BINDING)
          klass = director_klass.constantize
        end
        klass.new(page, self)
      end

      def find_page(url)
        found = Page.find_by_path(url, live?)
        found if found and (found.published? or dev?)
      end

      def process_page(page)
        page.pagination_parameters = pagination_parameters
        page.process(request, response)
      end

      def dev?
        request.host == detail['dev.host'] || request.host =~ /^dev\./
      end

      def live?
        not dev?
      end
  end
end