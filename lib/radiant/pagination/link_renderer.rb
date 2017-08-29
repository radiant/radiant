# This handy simplification is adapted from SphinxSearch (thanks)
# and originally came from Ultrasphinx
# it saves us a lot of including and bodging to make will_paginate's template calls work in the Page model

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