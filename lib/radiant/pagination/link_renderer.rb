# This handy simplification is adapted from SphinxSearch (thanks)
# and originally came from Ultrasphinx
# it saves us a lot of including and bodging to make will_paginate's template calls work in the Page model

module Radiant
  module Pagination
    class LinkRenderer < WillPaginate::LinkRenderer
      def initialize(url_stem)
        @url_stem = url_stem
      end
  
      def to_html
        links = @options[:page_links] ? windowed_links : []
        links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
        links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
        html = links.join(@options[:separator])
        @options[:container] ? %{<div class="pagination">#{html}</div>} : html
      end
      
      # this is rather crude compared to the WillPaginate link-builder,
      # but it can get by without much context to draw on
      def page_link(page, text, attributes = {})
        linkclass = %{ class="#{attributes[:class]}"} if attributes[:class]
        linkrel = %{ rel="#{attributes[:rel]}"} if attributes[:rel]
        param_name = WillPaginate::ViewHelpers.pagination_options[:param_name]
        %Q{<a href="#{@url_stem}?#{param_name}=#{page}"#{linkrel}#{linkclass}>#{text}</a>}
      end

      def page_span(page, text, attributes = {})
        %{<span class="#{attributes[:class]}">#{text}</span>}
      end
    end
  end
end