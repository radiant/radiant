module DeprecatedTags
  include Radiant::Taggable

  deprecated_tag "comment", :substitute => "hide", :deadline => '2.0'

  deprecated_tag "meta", :deadline => '2.0' do |tag|
    if tag.double?
      tag.expand
    else
      tag.render('description', tag.attr) + tag.render('keywords', tag.attr)
    end
  end

  deprecated_tag 'meta:description', :deadline => '2.0' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    description = CGI.escapeHTML(tag.locals.page.field(:description).try(:content))
    if show_tag
      "<meta name=\"description\" content=\"#{description}\" />"
    else
      description
    end
  end

  deprecated_tag 'meta:keywords', :deadline => '2.0' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    keywords = CGI.escapeHTML(tag.locals.page.field(:keywords).try(:content))
    if show_tag
      "<meta name=\"keywords\" content=\"#{keywords}\" />"
    else
      keywords
    end
  end
  
end