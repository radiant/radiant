class ArchiveMonthIndexPage < Page
  
  description %{
    To create a month index for an archive, create a child page for the
    archive and assign the "Archive Month Index" page type to it.
    
    A month index page makes following tags available to you:
    
    <r:archive:children>...</r:archive:children>
      Grants access to a subset of the children of the archive page
      that match the specific year which the index page is rendering.
  }
  
  include ArchiveIndexTagsAndMethods
  desc %{
      Grants access to a subset of the children of the archive page
      that match the specific month which the index page is rendering.
      
      *Usage*:
       <pre><code><r:archive:children>...</r:archive:children></code></pre>
  }
  tag "archive:children" do |tag|
    year, month = $1, $2 if request_uri =~ %r{/(\d{4})/(\d{2})/?$}
    tag.locals.children = ArchiveFinder.month_finder(parent.children, year, month)
    tag.expand
  end
  
end