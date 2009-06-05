Paperclipped
---

## IMPORTANT!

This version of Paperclipped requires Radiant 0.8.0 RC1 or higher. Changes in the caching system and the updgrade to Rails 2.3.2 break the previous versions of the extension. If you want to use Paperclipped with 0.7.1 please use the tagged version marked 0.7.1.

Paperclip is a new file management plugin from Thoughtbot which has a  few advantages over attachment_fu: it doesn't use RMagick, which uses a lot of RAM and is a bit of overkill for just making thumbnails. Instead it directly uses ImageMagick, making it much easier to install. 

This version of paperclipped adds:

* error reports if inline file uploads fail (eg they exceed the file size limit)

###Installation

To install paperclipped, just run 
 
	rake production db:migrate:extensions
	rake production radiant:extensions:paperclipped:update

This runs the database migrations and installs the javascripts, images and css.

###Configuration

If you install the Settings Extension (highly recommended), you can also easily adjust both the sizes of any additional thumbnails and which thumbnails are displayed in the image edit view. The default is the original file, but any image size can be used by giving in the name of that size. 

If you do install the Settings Extension you should be sure to add a config.exetensions line to your environment.rb file: 

    config.extensions = [ :settings, :all ]
   
Also the Settings Extension migration should be run before Paperclipped's migration.

You also need the ImageSize gem required in `environment.rb`:

    config.gem 'imagesize', :lib => 'image_size'

The configuration settings also enable a list of the allowed file types, maximum file size and should you need it, the path to your installation of Image Magick (this should not be needed, but I sometimes had a problem when using mod_rails).

###Using Paperclipped

Once installed, you get a new Tab with the entire assets library, a Bucket à la Mephisto (though only the concept is stolen) and a search. You can also easily attach assets to any page and directly upload them to a page.

###Asset Tags

There are a veriety of new tags. The basic tag is the <code><r:assets /></code> tag, which can be used either alone or as a double tag. This tag requires the "title" attribute, which references the asset. If you use the drag and drop from the asset bucket, this title will be added for you. 

The <code><r:assets /></code> tag can be combined with other tags for a variety of uses: 

    <r:assets:image title="foo" /> will return <img src="/path/to/foo" alt="foo" />

    <r:assets:link title="foo" /> will return <a href="/path/to/foo">foo</a>

You could also use: 

    <r:assets:link title="foo" text="This is the link to foo" /> will return <a href="/path/to/foo">This is the link to foo</a>

or 

    <r:assets:link title="foo">This is another link</r:link>

Asset links are also available, such as content_type, file_size, and url. 

Another important tag is the <code><r:assets:each>...</r:assets:each></code>. If a page has attached assets, the assets:each tag will cycle through each asset. You can then use an image, link or url tag to display or connect your assets. Usage:

    <r:assets:each [limit=0] [offset=0] [order="asc|desc"] [by="position|title|..."] [extensions="png|pdf|doc"]>
      ...
    </r:assets:each>

`<r:assets:each>` parameters:

* `limit` and `offset` let you specify a range of assets;
* `order` and `by` lets you control sorting;
* `extensions` allows you to filter assets by file extensions; you can specify multiple extensions separated by `|`.

<code><pre>`<r:if_assets [min_count="0"]>` and `<r:unless_assets [min_count="0"]>` 
</code></pre>
  
conditional tags let you optionally render content based on the existance of tags. They accept the same options as `<r:assets:each>`.

Thumbnails are automatically generated for images when the images are uploaded. By default, two sizes are made for use within the extension itself. These are "icon" 42px by 42px and "thumbnail" which is fit into 100px, maintaining its aspect ratio.

You can access sizes of image assets for various versions with the tags `<r:assets:width [size="original"]/>` and `<r:assets:height [size="original"]/>`.

Also, for vertical centering of images, you have the handy `<r:assets:top_padding container="<container height>" [size="icon"]/>` tag. Working example:
  

    <ul>
      <r:assets:each>
        <li style="height:140px">
          <img style="padding-top:<r:top_padding size='category' container='140' />px" 
               src="<r:url />" alt="<r:title />" />
        </li>
      </r:assets:each>
    </ul>
   
    
###Using Amazon s3
Everything works as before, but now if you want to add S3 support, you simply set the storage setting to "s3". 

<pre><code>Radiant::Config[assets.storage] = "s3"</code></pre>
 
Then add 3 new settings with your Amazon credentials, either in the console or with the [Settings](http://github.com/Squeegy/radiant-settings/tree/master) extension:

<pre><code>Radiant::Config[assets.s3.bucket] = "my_supercool_bucket"
Radiant::Config[assets.s3.key] = "123456"
Radiant::Config[assets.s3.secret] = "123456789ABCDEF"
</code></pre>

and finally the path you want to use within your bucket, which uses the same notation as the Paperclip plugin.

<pre><code>Radiant::Config[assets.s3.path] = :class/:id/:basename_:style.:extension 
</code></pre>

The path setting, along with a new <code>url</code> setting can be used with the file system to customize both the path and url of your assets.

###Migrating from the page_attachments extension

If you're moving from page_attachments to paperclipped, here's how to migrate smoothly:

First, remove or disable the page_attachments extension, and install the paperclipped extension.
For example:

<pre><code>rake ray:dis name=page_attachments
rake ray:assets
</code></pre>
    
  
The migration has now copied your original `page_attachments` table to `old_page_attachments`.

<pre><code>rake radiant:extensions:paperclipped:migrate_from_page_attachments
</code></pre>
  
This rake task will create paperclipped-style attachments for all `OldPageAttachments`. It will also ask you if you want to clean up the old table and thumbnails in `/public/page_attachments`.

Done!