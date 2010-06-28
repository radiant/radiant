module Radiant
  module Pagination
    class LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
      def initialize(url_stem)
        @url_stem = url_stem
      end
      
      def url(page)
        "#{@url_stem}?#{param_name}=#{page}"
      end
    end
  end
end
