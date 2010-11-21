module DeprecatedTags
  include Radiant::Taggable

  desc %{
    This is deprecated and will be removed. Plase use @<r:hide>@
    Nothing inside a set of comment tags is rendered.

    *Usage:*

    <pre><code><r:comment>...</r:comment></code></pre>
  }
  tag 'comment' do |tag|
    ActiveSupport::Deprecation.warn("the <r:comment> tag is no longer encouraged in Radiant 0.9.2+; use <r:hide> instead.", caller)
  end

  desc %{
    The namespace for 'meta' attributes.  If used as a singleton tag, both the description
    and keywords fields will be output as &lt;meta /&gt; tags unless the attribute 'tag' is set to 'false'.

    *Usage:*

    <pre><code> <r:meta [tag="false"] />
     <r:meta>
       <r:description [tag="false"] />
       <r:keywords [tag="false"] />
     </r:meta>
    </code></pre>
  }
  tag 'meta' do |tag|
    ActiveSupport::Deprecation.warn("r:meta is deprecated. Please use r:field name='field_name' instead.", caller)
    if tag.double?
      tag.expand
    else
      tag.render('description', tag.attr) +
      tag.render('keywords', tag.attr)
    end
  end

  desc %{
    Emits the page description field in a meta tag, unless attribute
    'tag' is set to 'false'.

    *Usage:*

    <pre><code> <r:meta:description [tag="false"] /> </code></pre>
  }
  tag 'meta:description' do |tag|
    ActiveSupport::Deprecation.warn('r:meta:description is deprecated. Please use r:field name="Description" instead.', caller)
    show_tag = tag.attr['tag'] != 'false' || false
    description = CGI.escapeHTML(tag.locals.page.field(:description).try(:content))
    if show_tag
      "<meta name=\"description\" content=\"#{description}\" />"
    else
      description
    end
  end

  desc %{
    Emits the page keywords field in a meta tag, unless attribute
    'tag' is set to 'false'.

    *Usage:*

    <pre><code> <r:meta:keywords [tag="false"] /> </code></pre>
  }
  tag 'meta:keywords' do |tag|
    ActiveSupport::Deprecation.warn('r:meta:keywords is deprecated. Please use r:field name="Keywords" instead.', caller)
    show_tag = tag.attr['tag'] != 'false' || false
    keywords = CGI.escapeHTML(tag.locals.page.field(:keywords).try(:content))
    if show_tag
      "<meta name=\"keywords\" content=\"#{keywords}\" />"
    else
      keywords
    end
  end
  
end