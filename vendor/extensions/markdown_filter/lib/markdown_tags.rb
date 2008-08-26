module MarkdownTags
  include Radiant::Taggable

  desc %{
    Filters its contents with the Markdown filter.

    *Usage*:

    <pre><code><r:markdown>** bold text **</r:markdown></code></pre>

    produces:

    <pre><code><strong> bold text </strong></code></pre>
  }
  tag 'markdown' do |tag|
    MarkdownFilter.filter(tag.expand)
  end

  desc %{
    Filters its contents with the SmartyPants filter.

    *Usage*:

    <pre><code><r:smarty_pants>"A revolutionary quotation."</r:smarty_pants></code></pre>

    produces:

    <pre><code>&#8220;A revolutionary quotation.&#8221;</code></pre>
  }
  tag 'smarty_pants' do |tag|
    SmartyPantsFilter.filter(tag.expand)
  end
end