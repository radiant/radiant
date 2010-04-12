module UserTags
  include Radiant::Taggable
  
  desc %{
    Renders the name of the author of the current page.
  }
  tag 'author' do |tag|
    page = tag.locals.page
    if author = page.created_by
      author.name
    end
  end
end