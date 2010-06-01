# This handy simplification is adapted from SphinxSearch (thanks)
# and originally came from Ultrasphinx
# it saves us a lot of including and bodging to make will_paginate's template calls work in the Page model

module Radiant
  module Pagination
    class LinkRenderer < WillPaginate::LinkRenderer
      def initialize(tag)
        @url_stem = tag.locals.paginating_page.url if tag.locals.paginating_page
      end
  
      def to_html
        links = @options[:page_links] ? windowed_links : []
        links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
        links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
        html = links.join(@options[:separator])
        @options[:container] ? %{<div class="pagination">#{html}</div>} : html
      end
  
      def page_link(page, text, attributes = {})
        linkclass = %{ class="#{attributes[:class]}"} if attributes[:class]
        linkrel = %{ rel="#{attributes[:rel]}"} if attributes[:rel]
        %Q{<a href="#{@url_stem}?p=#{page}"#{linkrel}#{linkclass}>#{text}</a>}
      end

      def page_span(page, text, attributes = {})
        %{<span class="#{attributes[:class]}">#{text}</span>}
      end
    end
  end
end