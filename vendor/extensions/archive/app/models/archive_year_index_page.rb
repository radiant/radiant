class ArchiveYearIndexPage < Page
  
  description %{
    To create a year index for an archive, create a child page for the
    archive and assign the "Archive Year Index" page type to it.
    
    A year index page makes following tags available to you:
    
    <r:archive:children>...</r:archive:children>
      Grants access to a subset of the children of the archive page
      that match the specific year which the index page is rendering.
  }
  
  include ArchiveIndexTagsAndMethods
  desc %{
      Grants access to a subset of the children of the archive page
      that match the specific year which the index page is rendering.
      
      *Usage*:
       <pre><code><r:archive:children>...</r:archive:children></code></pre>
  }
  tag "archive:children" do |tag|
    year = $1 if request_uri =~ %r{/(\d{4})/?$}
    tag.locals.children = ArchiveFinder.year_finder(parent.children, year)
    tag.expand
  end
  
end