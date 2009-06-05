Paperclipped
---

Paperclip is a new file management plugin from Thoughtbot which has a  few advantages over attachment_fu: it doesn't use RMagick, which uses a lot of RAM and is a bit of overkill for just making thumbnails. Instead it directly uses ImageMagick, making it much easier to install. 


###Installation

To install paperclipped, just run 
 
	rake production db:migrate:extensions
	rake production radiant:extensions:paperclipped:update

This runs the database migrations and installs the javascripts, images and css.

###Configuration

If you install the Setting Extension (highly recommended), you can also easily adjust both the sizes of any additional thumbnails and which thumbnails are displayed in the image edit view. The default is the original file, but any image size can be used by giving in the name of that size. 

The configuration settings also enable a list of the allowed file types, maximum file size and should you need it, the path to your installation of Image Magick (this should not be needed, but I sometimes had a problem when using mod_rails).

###Using Paperclipped

Once installed, you get a new Tab with the entire assets library, a Bucket à la Mephisto (though only the concept is stolen) and a search. You can also easily attach assets to any page and directly upload them to a page.

###Asset Tags

There are a veriety of new tags. The basic tag is the <r:assets /> tag, which can be used either alone or as a double tag. This tag requires the "title" attribute, which references the asset. If you use the drag and drop from the asset bucket, this title will be added for you. 

The *&lt;r:assets /&gt;* tag can be combined with other tags for a variety of uses: 

    <r:assets:image title="foo" /> will return <img src="/path/to/foo" alt="foo" />
    <r:assets:link title="foo" /> will return <a href="/path/to/foo">foo</a>

You could also use: 

    <r:assets:link title="foo" text="This is the link to foo" /> will return <a href="/path/to/foo">This is the link to foo</a>

or 

    <rassets:link title="foo">This is another link</r:link>

Asset links are also available, such as content_type, file_size, and url. 

Another important tag is the *&lt;r:assets:each&gt;...&lt;/r:assets:each&gt;*. If a page has attached assets, the assets:each tag will cycle through each asset. You can then use an image, link or url tag to display or connect your assets. 

Thumbnails are automatically geneerated for images when the images are uploaded. By default, two sizes are made for use within the extension itself. These are "icon" 42px by 42px and "thumbnail" which is fit into 100px, maintaining its aspect ratio. 

###Migrating from the page_attachments extension

If you're moving from page_attachments to paperclipped, here's how to migrate smoothly;

First, remove or disable the page_attachments extension, and install the paperclipped extension.
For example:

    rake ray:dis name=page_attachments
    rake ray:assets

or

    rm -rf vendor/extensions/page_attachments
    script/extension install 
  
The migration has now copied your original page_attachments table to old_page_attachments.

    rake radiant:extensions:paperclipped:migrate_from_page_attachments
  
This rake task will create paperclipped-style attachments for all OldPageAttachments. It will also ask you if you want to clean up the old table and thumbnails in /public/page_attachments.
Done!