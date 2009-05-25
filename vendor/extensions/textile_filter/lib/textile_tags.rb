module TextileTags
  include Radiant::Taggable

  desc %{
  #{I18n.t('tag_desc.textile.desc')}

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:textile>
    *&nbsp;First
    *&nbsp;Second<br>&lt;/r:textile&gt;</code></pre>

    #{I18n.t('tag_desc.produces')}:

    <pre><code><ul>
   &lt;li&gt;First&lt;/li&gt;
   &lt;li&gt;Second&lt;/li&gt;<br>&lt;/ul&gt;</code></pre>
  }
  tag 'textile' do |tag|
    TextileFilter.filter(tag.expand)
  end
end