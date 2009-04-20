module StandardTags

  include Radiant::Taggable
  include LocalTime

  class TagError < StandardError; end

  desc %{
    #{I18n.t('tag_desc.page.desc')}

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:page>...</r:page></code></pre>
  }
  
  tag 'page' do |tag|
    tag.locals.page = tag.globals.page
    tag.expand
  end

  [:breadcrumb, :slug, :title].each do |method|
    desc I18n.t('tag_desc.page.attributes', :method => method)
    tag method.to_s do |tag|
      tag.locals.page.send(method)
    end
  end

  desc I18n.t('tag_desc.page.url')
  tag 'url' do |tag|
    relative_url_for(tag.locals.page.url, tag.globals.page.request)
  end

  desc %{ 
    #{I18n.t('tag_desc.children.desc')}

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children>...</r:children></code></pre>
  }
  tag 'children' do |tag|
    tag.locals.children = tag.locals.page.children
    tag.expand
  end

  desc I18n.t('tag_desc.children.count')
  tag 'children:count' do |tag|
    tag.locals.children.count(children_find_options(tag))
  end

  desc %{
    #{I18n.t('tag_desc.children.first')}

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:first>...</r:children:first></code></pre>
  }
  tag 'children:first' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if first = children.first
      tag.locals.page = first
      tag.expand
    end
  end

  desc %{
    #{I18n.t('tag_desc.children.last')}

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:last>...</r:children:last></code></pre>
  }
  tag 'children:last' do |tag|
    options = children_find_options(tag)
    children = tag.locals.children.find(:all, options)
    if last = children.last
      tag.locals.page = last
      tag.expand
    end
  end

  desc %{
    #{I18n.t('tag_desc.children.each')}

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each [offset="number"] [limit="number"] [by="attribute"] [order="asc|desc"]
     [status="draft|reviewed|published|hidden|all"]>
     ...
    </r:children:each>
    </code></pre>
  }
  tag 'children:each' do |tag|
    options = children_find_options(tag)
    result = []
    children = tag.locals.children
    tag.locals.previous_headers = {}
    kids = children.find(:all, options)
    kids.each_with_index do |item, i|
      tag.locals.child = item
      tag.locals.page = item
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == kids.length - 1
      result << tag.expand
    end
    result
  end

  desc %{
    #{I18n.t('tag_desc.children.child')}

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each>
      <r:child>...</r:child>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:child' do |tag|
    tag.locals.page = tag.locals.child
    tag.expand
  end
  
  desc %{
    Renders the tag contents only if the current page is the first child in the context of
    a children:each tag
    
    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each>
      <r:if_first >
        ...
      </r:if_first>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:if_first' do |tag|
    tag.expand if tag.locals.first_child
  end

  
  desc %{
    Renders the tag contents unless the current page is the first child in the context of
    a children:each tag
    
    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each>
      <r:unless_first >
        ...
      </r:unless_first>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:unless_first' do |tag|
    tag.expand unless tag.locals.first_child
  end
  
  desc %{
    Renders the tag contents only if the current page is the last child in the context of
    a children:each tag
    
    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each>
      <r:if_last >
        ...
      </r:if_last>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:if_last' do |tag|
    tag.expand if tag.locals.last_child
  end

  
  desc %{
    Renders the tag contents unless the current page is the last child in the context of
    a children:each tag
    
    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each>
      <r:unless_last >
        ...
      </r:unless_last>
    </r:children:each>
    </code></pre>
    
  }
  tag 'children:each:unless_last' do |tag|
    tag.expand unless tag.locals.last_child
  end
  
  desc %{
    Renders the tag contents only if the contents do not match the previous header. This
    is extremely useful for rendering date headers for a list of child pages.

    If you would like to use several header blocks you may use the @name@ attribute to
    name the header. When a header is named it will not restart until another header of
    the same name is different.

    Using the @restart@ attribute you can cause other named headers to restart when the
    present header changes. Simply specify the names of the other headers in a semicolon
    separated list.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:children:each>
      <r:header [name="header_name"] [restart="name1[;name2;...]"]>
        ...
      </r:header>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:header' do |tag|
    previous_headers = tag.locals.previous_headers
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    header = tag.expand
    unless header == previous_headers[name]
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      header
    end
  end

  desc %{
    Page attribute tags inside this tag refer to the parent of the current page.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:parent>...</r:parent></code></pre>
  }
  tag "parent" do |tag|
    parent = tag.locals.page.parent
    tag.locals.page = parent
    tag.expand if parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has a parent, i.e.
    is not the root page.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:if_parent>...</r:if_parent></code></pre>
  }
  tag "if_parent" do |tag|
    parent = tag.locals.page.parent
    tag.expand if parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has no parent, i.e.
    is the root page.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:unless_parent>...</r:unless_parent></code></pre>
  }
  tag "unless_parent" do |tag|
    parent = tag.locals.page.parent
    tag.expand unless parent
  end

  desc %{
    Renders the contained elements only if the current contextual page has one or
    more child pages.  The @status@ attribute limits the status of found child pages
    to the given status, the default is @"published"@. @status="all"@ includes all
    non-virtual pages regardless of status.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:if_children [status="published"]>...</r:if_children></code></pre>
  }
  tag "if_children" do |tag|
    children = tag.locals.page.children.count(:conditions => children_find_options(tag)[:conditions])
    tag.expand if children > 0
  end

  desc %{
    Renders the contained elements only if the current contextual page has no children.
    The @status@ attribute limits the status of found child pages to the given status,
    the default is @"published"@. @status="all"@ includes all non-virtual pages
    regardless of status.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:unless_children [status="published"]>...</r:unless_children></code></pre>
  }
  tag "unless_children" do |tag|
    children = tag.locals.page.children.count(:conditions => children_find_options(tag)[:conditions])
    tag.expand unless children > 0
  end

  desc %{
    Renders one of the passed values based on a global cycle counter.  Use the @reset@
    attribute to reset the cycle to the beginning.  Use the @name@ attribute to track
    multiple cycles; the default is @cycle@.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:cycle values="first, second, third" [reset="true|false"] [name="cycle"] /></code></pre>
  }
  tag 'cycle' do |tag|
    raise TagError, "`cycle' tag must contain a `values' attribute." unless tag.attr['values']
    cycle = (tag.globals.cycle ||= {})
    values = tag.attr['values'].split(",").collect(&:strip)
    cycle_name = tag.attr['name'] || 'cycle'
    current_index = (cycle[cycle_name] ||=  0)
    current_index = 0 if tag.attr['reset'] == 'true'
    cycle[cycle_name] = (current_index + 1) % values.size
    values[current_index]
  end

  desc %{
    Renders the main content of a page. Use the @part@ attribute to select a specific
    page part. By default the @part@ attribute is set to body. Use the @inherit@
    attribute to specify that if a page does not have a content part by that name that
    the tag should render the parent's content part. By default @inherit@ is set to
    @false@. Use the @contextual@ attribute to force a part inherited from a parent
    part to be evaluated in the context of the child page. By default 'contextual'
    is set to true.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:content [part="part_name"] [inherit="true|false"] [contextual="true|false"] /></code></pre>
  }
  tag 'content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    boolean_attr = proc do |attribute_name, default|
      attribute = (tag.attr[attribute_name] || default).to_s
      raise TagError.new(%{`#{attribute_name}' attribute of `content' tag must be set to either "true" or "false"}) unless attribute =~ /true|false/i
      (attribute.downcase == 'true') ? true : false
    end
    inherit = boolean_attr['inherit', false]
    part_page = page
    if inherit
      while (part_page.part(part_name).nil? and (not part_page.parent.nil?)) do
        part_page = part_page.parent
      end
    end
    contextual = boolean_attr['contextual', true]
    part = part_page.part(part_name)
    tag.locals.page = part_page unless contextual
    tag.globals.page.render_snippet(part) unless part.nil?
  end

  desc %{
    Renders the containing elements if all of the listed parts exist on a page.
    By default the @part@ attribute is set to @body@, but you may list more than one
    part by separating them with a comma. Setting the optional @inherit@ to true will
    search ancestors independently for each part. By default @inherit@ is set to @false@.

    When listing more than one part, you may optionally set the @find@ attribute to @any@
    so that it will render the containing elements if any of the listed parts are found.
    By default the @find@ attribute is set to @all@.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:if_content [part="part_name, other_part"] [inherit="true"] [find="any"]>...</r:if_content></code></pre>
  }
  tag 'if_content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    parts_arr = part_name.split(',')
    inherit = boolean_attr_or_error(tag, 'inherit', 'false')
    find = attr_or_error(tag, :attribute_name => 'find', :default => 'all', :values => 'any, all')
    expandable = true
    one_found = false
    part_page = page
    parts_arr.each do |name|
      name.strip!
      if inherit
        while (part_page.part(name).nil? and (not part_page.parent.nil?)) do
          part_page = part_page.parent
        end
      end
      expandable = false if part_page.part(name).nil?
      one_found ||= true if !part_page.part(name).nil?
    end
    expandable = true if (find == 'any' and one_found)
    tag.expand if expandable
  end

  desc %{
    The opposite of the @if_content@ tag. It renders the contained elements if all of the
    specified parts do not exist. Setting the optional @inherit@ to true will search
    ancestors independently for each part. By default @inherit@ is set to @false@.

    When listing more than one part, you may optionally set the @find@ attribute to @any@
    so that it will not render the containing elements if any of the listed parts are found.
    By default the @find@ attribute is set to @all@.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:unless_content [part="part_name, other_part"] [inherit="false"] [find="any"]>...</r:unless_content></code></pre>
  }
  tag 'unless_content' do |tag|
    page = tag.locals.page
    part_name = tag_part_name(tag)
    parts_arr = part_name.split(',')
    inherit = boolean_attr_or_error(tag, 'inherit', false)
    find = attr_or_error(tag, :attribute_name => 'find', :default => 'all', :values => 'any, all')
    expandable, all_found = true, true
    part_page = page
    parts_arr.each do |name|
      name.strip!
      if inherit
        while (part_page.part(name).nil? and (not part_page.parent.nil?)) do
          part_page = part_page.parent
        end
      end
      expandable = false if !part_page.part(name).nil?
      all_found = false if part_page.part(name).nil?
    end
    if all_found == false and find == 'all'
      expandable = true
    end
    tag.expand if expandable
  end

  desc %{
    Renders the containing elements only if the page's url matches the regular expression
    given in the @matches@ attribute. If the @ignore_case@ attribute is set to false, the
    match is case sensitive. By default, @ignore_case@ is set to true.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:if_url matches="regexp" [ignore_case="true|false"]>...</r:if_url></code></pre>
  }
  tag 'if_url' do |tag|
    raise TagError.new("`if_url' tag must contain a `matches' attribute.") unless tag.attr.has_key?('matches')
    regexp = build_regexp_for(tag, 'matches')
    unless tag.locals.page.url.match(regexp).nil?
       tag.expand
    end
  end

  desc %{
    The opposite of the @if_url@ tag.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:unless_url matches="regexp" [ignore_case="true|false"]>...</r:unless_url></code></pre>
  }
  tag 'unless_url' do |tag|
    raise TagError.new("`unless_url' tag must contain a `matches' attribute.") unless tag.attr.has_key?('matches')
    regexp = build_regexp_for(tag, 'matches')
    if tag.locals.page.url.match(regexp).nil?
        tag.expand
    end
  end

  desc %{
    Renders the contained elements if the current contextual page is either the actual page or one of its parents.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up if the child element is or descends from the current page.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:if_ancestor_or_self>...</r:if_ancestor_or_self></code></pre>
  }
  tag "if_ancestor_or_self" do |tag|
    tag.expand if (tag.globals.page.ancestors + [tag.globals.page]).include?(tag.locals.page)
  end

  desc %{
    Renders the contained elements unless the current contextual page is either the actual page or one of its parents.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up unless the child element is or descends from the current page.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:unless_ancestor_or_self>...</r:unless_ancestor_or_self></code></pre>
  }
  tag "unless_ancestor_or_self" do |tag|
    tag.expand unless (tag.globals.page.ancestors + [tag.globals.page]).include?(tag.locals.page)
  end

  desc %{
    Renders the contained elements if the current contextual page is also the actual page.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up if the child element is the current page.

    *#{I18n.t('tag_desc.usage')}:*
    
    <pre><code><r:if_self>...</r:if_self></code></pre>
  }
  tag "if_self" do |tag|
    tag.expand if tag.locals.page == tag.globals.page
  end

  desc %{
    Renders the contained elements unless the current contextual page is also the actual page.

    This is typically used inside another tag (like &lt;r:children:each&gt;) to add conditional mark-up unless the child element is the current page.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:unless_self>...</r:unless_self></code></pre>
  }
  tag "unless_self" do |tag|
    tag.expand unless tag.locals.page == tag.globals.page
  end

  desc %{
    Renders the name of the author of the current page.
  }
  tag 'author' do |tag|
    page = tag.locals.page
    if author = page.created_by
      author.name
    end
  end

  desc %{
    Renders the date based on the current page (by default when it was published or created).
    The format attribute uses the same formating codes used by the Ruby @strftime@ function. By
    default it's set to @%A, %B %d, %Y@.  The @for@ attribute selects which date to render.  Valid
    options are @published_at@, @created_at@, @updated_at@, and @now@. @now@ will render the
    current date/time, regardless of the  page.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:date [format="%A, %B %d, %Y"] [for="published_at"]/></code></pre>
  }
  tag 'date' do |tag|
    page = tag.locals.page
    format = (tag.attr['format'] || '%A, %B %d, %Y')
    time_attr = tag.attr['for']
    date = if time_attr
      case
      when time_attr == 'now'
        Time.now
      when ['published_at', 'created_at', 'updated_at'].include?(time_attr)
        page[time_attr]
      else
        raise TagError, "Invalid value for 'for' attribute."
      end
    else
      page.published_at || page.created_at
    end
    adjust_time(date).strftime(format)
  end

  desc %{
    Renders a link to the page. When used as a single tag it uses the page's title
    for the link name. When used as a double tag the part in between both tags will
    be used as the link text. The link tag passes all attributes over to the HTML
    @a@ tag. This is very useful for passing attributes like the @class@ attribute
    or @id@ attribute. If the @anchor@ attribute is passed to the tag it will
    append a pound sign (<code>#</code>) followed by the value of the attribute to
    the @href@ attribute of the HTML @a@ tag--effectively making an HTML anchor.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:link [anchor="name"] [other attributes...] /></code></pre>
    
    or
    
    <pre><code><r:link [anchor="name"] [other attributes...]>link text here</r:link></code></pre>
  }
  tag 'link' do |tag|
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    %{<a href="#{tag.render('url')}#{anchor}"#{attributes}>#{text}</a>}
  end

  desc %{
    Renders a trail of breadcrumbs to the current page. The separator attribute
    specifies the HTML fragment that is inserted between each of the breadcrumbs. By
    default it is set to @>@. The boolean nolinks attribute can be specified to render
    breadcrumbs in plain text, without any links (useful when generating title tag).

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:breadcrumbs [separator="separator_string"] [nolinks="true"] /></code></pre>
  }
  tag 'breadcrumbs' do |tag|
    page = tag.locals.page
    breadcrumbs = [page.breadcrumb]
    nolinks = (tag.attr['nolinks'] == 'true')
    page.ancestors.each do |ancestor|
      tag.locals.page = ancestor
      if nolinks
        breadcrumbs.unshift tag.render('breadcrumb')
      else
        breadcrumbs.unshift %{<a href="#{tag.render('url')}">#{tag.render('breadcrumb')}</a>}
      end
    end
    separator = tag.attr['separator'] || ' &gt; '
    breadcrumbs.join(separator)
  end

  desc %{
    Renders the snippet specified in the @name@ attribute within the context of a page.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:snippet name="snippet_name" /></code></pre>

    When used as a double tag, the part in between both tags may be used within the
    snippet itself, being substituted in place of @<r:yield/>@.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:snippet name="snippet_name">Lorem ipsum dolor...</r:snippet></code></pre>
  }
  tag 'snippet' do |tag|
    if name = tag.attr['name']
      if snippet = Snippet.find_by_name(name.strip)
        tag.locals.yield = tag.expand if tag.double?
        tag.globals.page.render_snippet(snippet)
      else
        raise TagError.new('snippet not found')
      end
    else
      raise TagError.new("`snippet' tag must contain `name' attribute")
    end
  end

  desc %{
    Used within a snippet as a placeholder for substitution of child content, when
    the snippet is called as a double tag.

    *Usage (within a snippet):*
    
    <pre><code>
    <div id="outer">
      <p>before</p>
      <r:yield/>
      <p>after</p>
    </div>
    </code></pre>

    If the above snippet was named "yielding", you could call it from any Page,
    Layout or Snippet as follows:

    <pre><code><r:snippet name="yielding">Content within</r:snippet></code></pre>

    Which would output the following:

    <pre><code>
    <div id="outer">
      <p>before</p>
      Content within
      <p>after</p>
    </div>
    </code></pre>

    When called in the context of a Page or a Layout, @<r:yield/>@ outputs nothing.
  }
  tag 'yield' do |tag|
    tag.locals.yield
  end

  desc %{
    Inside this tag all page related tags refer to the page found at the @url@ attribute.
    @url@s may be relative or absolute paths.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:find url="value_to_find">...</r:find></code></pre>
  }
  tag 'find' do |tag|
    url = tag.attr['url']
    raise TagError.new("`find' tag must contain `url' attribute") unless url

    found = Page.find_by_url(absolute_path_for(tag.locals.page.url, url))
    if page_found?(found)
      tag.locals.page = found
      tag.expand
    end
  end

  desc %{
    Randomly renders one of the options specified by the @option@ tags.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:random>
      <r:option>...</r:option>
      <r:option>...</r:option>
      ...
    <r:random>
    </code></pre>
  }
  tag 'random' do |tag|
    tag.locals.random = []
    tag.expand
    options = tag.locals.random
    option = options[rand(options.size)]
    option if option
  end
  tag 'random:option' do |tag|
    items = tag.locals.random
    items << tag.expand
  end

  desc %{
    Nothing inside a set of comment tags is rendered.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:comment>...</r:comment></code></pre>
  }
  tag 'comment' do |tag|
  end

  desc %{
    Escapes angle brackets, etc. for rendering in an HTML document.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:escape_html>...</r:escape_html></code></pre>
  }
  tag "escape_html" do |tag|
    CGI.escapeHTML(tag.expand)
  end

  desc %{
    Outputs the published date using the format mandated by RFC 1123. (Ideal for RSS feeds.)

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:rfc1123_date /></code></pre>
  }
  tag "rfc1123_date" do |tag|
    page = tag.locals.page
    if date = page.published_at || page.created_at
      CGI.rfc1123_date(date.to_time)
    end
  end

  desc %{
    Renders a list of links specified in the @urls@ attribute according to three
    states:

    * @normal@ specifies the normal state for the link
    * @here@ specifies the state of the link when the url matches the current
       page's URL
    * @selected@ specifies the state of the link when the current page matches
       is a child of the specified url

    The @between@ tag specifies what should be inserted in between each of the links.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:navigation urls="[Title: url | Title: url | ...]">
      <r:normal><a href="<r:url />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><strong><a href="<r:url />"><r:title /></a></strong></r:selected>
      <r:between> | </r:between>
    </r:navigation>
    </code></pre>
  }
  tag 'navigation' do |tag|
    hash = tag.locals.navigation = {}
    tag.expand
    raise TagError.new("`navigation' tag must include a `normal' tag") unless hash.has_key? :normal
    result = []
    pairs = tag.attr['urls'].to_s.split('|').map do |pair|
      parts = pair.split(':')
      value = parts.pop
      key = parts.join(':')
      [key.strip, value.strip]
    end
    pairs.each do |title, url|
      compare_url = remove_trailing_slash(url)
      page_url = remove_trailing_slash(self.url)
      hash[:title] = title
      hash[:url] = url
      case page_url
      when compare_url
        result << (hash[:here] || hash[:selected] || hash[:normal]).call
      when Regexp.compile( '^' + Regexp.quote(url))
        result << (hash[:selected] || hash[:normal]).call
      else
        result << hash[:normal].call
      end
    end
    between = hash.has_key?(:between) ? hash[:between].call : ' '
    result.reject { |i| i.blank? }.join(between)
  end
  [:normal, :here, :selected, :between].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol] = tag.block
    end
  end
  [:title, :url].each do |symbol|
    tag "navigation:#{symbol}" do |tag|
      hash = tag.locals.navigation
      hash[symbol]
    end
  end

  desc %{
    Renders the containing elements only if Radiant in is development mode.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:if_dev>...</r:if_dev></code></pre>
  }
  tag 'if_dev' do |tag|
    tag.expand if dev?(tag.globals.page.request)
  end

  desc %{
    The opposite of the @if_dev@ tag.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:unless_dev>...</r:unless_dev></code></pre>
  }
  tag 'unless_dev' do |tag|
    tag.expand unless dev?(tag.globals.page.request)
  end

  desc %{
    Prints the page's status as a string.  Optional attribute 'downcase'
    will cause the status to be all lowercase.

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:status [downcase='true'] /></code></pre>
  }
  tag 'status' do |tag|
    status = tag.globals.page.status.name
    return status.downcase if tag.attr['downcase']
    status
  end

  desc %{
    The namespace for 'meta' attributes.  If used as a singleton tag, both the description
    and keywords fields will be output as &lt;meta /&gt; tags unless the attribute 'tag' is set to 'false'.

    *Usage*:

    <pre><code> <r:meta [tag="false"] />
     <r:meta>
       <r:description [tag="false"] />
       <r:keywords [tag="false"] />
     </r:meta>
    </code></pre>
  }
  tag 'meta' do |tag|
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

    *Usage*:

    <pre><code> <r:meta:description [tag="false"] /> </code></pre>
  }
  tag 'meta:description' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    description = CGI.escapeHTML(tag.locals.page.description)
    if show_tag
      "<meta name=\"description\" content=\"#{description}\" />"
    else
      description
    end
  end

  desc %{
    Emits the page keywords field in a meta tag, unless attribute
    'tag' is set to 'false'.

    *Usage*:

    <pre><code> <r:meta:keywords [tag="false"] /> </code></pre>
  }
  tag 'meta:keywords' do |tag|
    show_tag = tag.attr['tag'] != 'false' || false
    keywords = CGI.escapeHTML(tag.locals.page.keywords)
    if show_tag
      "<meta name=\"keywords\" content=\"#{keywords}\" />"
    else
      keywords
    end
  end

  private

    def children_find_options(tag)
      attr = tag.attr.symbolize_keys

      options = {}

      [:limit, :offset].each do |symbol|
        if number = attr[symbol]
          if number =~ /^\d{1,4}$/
            options[symbol] = number.to_i
          else
            raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
          end
        end
      end

      by = (attr[:by] || 'published_at').strip
      order = (attr[:order] || 'asc').strip
      order_string = ''
      if self.attributes.keys.include?(by)
        order_string << by
      else
        raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
      end
      if order =~ /^(asc|desc)$/i
        order_string << " #{$1.upcase}"
      else
        raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
      end
      options[:order] = order_string

      status = (attr[:status] || ( dev?(tag.globals.page.request) ? 'all' : 'published')).downcase
      unless status == 'all'
        stat = Status[status]
        unless stat.nil?
          options[:conditions] = ["(virtual = ?) and (status_id = ?)", false, stat.id]
        else
          raise TagError.new(%{`status' attribute of `each' tag must be set to a valid status})
        end
      else
        options[:conditions] = ["virtual = ?", false]
      end
      options
    end

    def remove_trailing_slash(string)
      (string =~ %r{^(.*?)/$}) ? $1 : string
    end

    def tag_part_name(tag)
      tag.attr['part'] || 'body'
    end

    def build_regexp_for(tag, attribute_name)
      ignore_case = tag.attr.has_key?('ignore_case') && tag.attr['ignore_case']=='false' ? nil : true
      begin
        regexp = Regexp.new(tag.attr['matches'], ignore_case)
      rescue RegexpError => e
        raise TagError.new("Malformed regular expression in `#{attribute_name}' argument of `#{tag.name}' tag: #{e.message}")
      end
      regexp
    end

    def relative_url_for(url, request)
      File.join(ActionController::Base.relative_url_root || '', url)
    end

    def absolute_path_for(base_path, new_path)
      if new_path.first == '/'
        new_path
      else
        File.expand_path(File.join(base_path, new_path))
      end
    end

    def page_found?(page)
      page && !(FileNotFoundPage === page)
    end

    def boolean_attr_or_error(tag, attribute_name, default)
      attribute = attr_or_error(tag, :attribute_name => attribute_name, :default => default.to_s, :values => 'true, false')
      (attribute.to_s.downcase == 'true') ? true : false
    end

    def attr_or_error(tag, options = {})
      attribute_name = options[:attribute_name].to_s
      default = options[:default]
      values = options[:values].split(',').map!(&:strip)

      attribute = (tag.attr[attribute_name] || default).to_s
      raise TagError.new(%{'#{attribute_name}' attribute of #{tag} tag must be one of: #{values.join(',')}}) unless values.include?(attribute)
      return attribute
    end

    def dev?(request)
      dev_host = Radiant::Config['dev.host']
      request && ((dev_host && dev_host == request.host) || request.host =~ /^dev\./)
    end
end
