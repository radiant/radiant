require 'radiant/taggable'
module DeprecatedTags
  include Radiant::Taggable

  deprecated_tag "rfc1123_date", :deadline => '2.0' do |tag|
    page = tag.locals.page
    if date = page.published_at || page.created_at
      CGI.rfc1123_date(date.to_time)
    end
  end

end
