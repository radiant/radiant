module MarkdownTags
  include Radiant::Taggable

  desc %{
  #{I18n.t('tag_desc.markdown.desc')}

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:markdown>** bold text **</r:markdown></code></pre>

    #{I18n.t('tag_desc.produces')}:

    <pre><code><strong> bold text </strong></code></pre>
  }
  tag 'markdown' do |tag|
    MarkdownFilter.filter(tag.expand)
  end

  desc %{
    #{I18n.t('tag_desc.smarty_pants.desc')}

    *#{I18n.t('tag_desc.usage')}:*

    <pre><code><r:smarty_pants>"A revolutionary quotation."</r:smarty_pants></code></pre>

    #{I18n.t('tag_desc.produces')}:

    <pre><code>&#8220;A revolutionary quotation.&#8221;</code></pre>
  }
  tag 'smarty_pants' do |tag|
    SmartyPantsFilter.filter(tag.expand)
  end
end