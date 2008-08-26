module TextileTags
  include Radiant::Taggable

  desc %{
    Filters its contents with the Textile filter.

    *Usage*:

    <pre><code><r:textile>
    * First
    * Second
    </r:textile></code></pre>

    produces:

    <pre><code><ul>
      <li>First</li>
      <li>Second</li>
    </ul></code></pre>
  }
  tag 'textile' do |tag|
    TextileFilter.filter(tag.expand)
  end
end