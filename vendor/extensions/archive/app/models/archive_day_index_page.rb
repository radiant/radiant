class ArchiveDayIndexPage < Page
  
  description %{
    To create a day index for an archive, create a child page for the
    archive and assign the "Archive Day Index" page type to it.
    
    A day index page makes following tags available to you:
    
    <r:archive:children>...</r:archive:children>
      Grants access to a subset of the children of the archive page
      that match the specific year which the index page is rendering.
  }
  
  include ArchiveIndexTagsAndMethods
  desc %{
      Grants access to a subset of the children of the archive page
      that match the specific day which the index page is rendering.
      
      *Usage*:
       <pre><code><r:archive:children>...</r:archive:children></code></pre>
  }
  tag "archive:children" do |tag|
    year, month, day = $1, $2, $3 if request_uri =~ %r{/(\d{4})/(\d{2})/(\d{2})/?$}
    tag.locals.children = ArchiveFinder.day_finder(parent.children, year, month, day)
    tag.expand
  end
  
end