module MarkdownTags
  include Radiant::Taggable

  desc %{
    Filters its contents with the Markdown filter.

    *Usage:*

    <pre><code><r:markdown>** bold text **</r:markdown></code></pre>

    produces

    <pre><code><strong> bold text </strong></code></pre>
  }
  tag 'markdown' do |tag|
    MarkdownFilter.filter(tag.expand)
  end
end