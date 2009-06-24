class Asset < ActiveRecord::Base
  
  class << self
    def image?(asset_content_type)
      image_content_types.include?(asset_content_type)
    end
    
    def movie?(asset_content_type)
      asset_content_type.to_s =~ /^video/ || extra_content_types[:movie].include?(asset_content_type)
    end
        
    def audio?(asset_content_type)
      asset_content_type.to_s =~ /^audio/ || extra_content_types[:audio].include?(asset_content_type)
    end
    
    def other?(asset_content_type)
      ![:image, :movie, :audio].any? { |a| send("#{a}?", asset_content_type) }
    end

    def pdf?(asset_content_type)
      extra_content_types[:pdf].include? asset_content_type
    end

    def find_all_by_content_types(types, *args)
      with_content_types(types) { find *args }
    end

    def with_content_types(types, &block)
      with_scope(:find => { :conditions => types_to_conditions(types).join(' OR ') }, &block)
    end

    def types_to_conditions(types)
      types.collect! { |t| '(' + send("#{t}_condition") + ')' }
    end
    
    def thumbnail_sizes
      if Radiant::Config.table_exists? && Radiant::Config["assets.additional_thumbnails"]
        thumbnails = additional_thumbnails
      else
        thumbnails = {}
      end
      thumbnails[:icon] = ['42x42#', :png]
      thumbnails[:thumbnail] = ['100x100>', :png]
      thumbnails
    end

    def thumbnail_names
      thumbnail_sizes.keys
    end
    
    private
      def additional_thumbnails
        Radiant::Config["assets.additional_thumbnails"].gsub(' ','').split(',').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
      end
  end
  
  # order_by 'title'
    
  has_attached_file :asset,
                    :styles => thumbnail_sizes,
                    :whiny_thumbnails => false,
                    :storage => Radiant::Config["assets.storage"] == "s3" ? :s3 : :filesystem, 
                    :s3_credentials => {
                      :access_key_id => Radiant::Config["assets.s3.key"],
                      :secret_access_key => Radiant::Config["assets.s3.secret"]
                    },
                    :bucket => Radiant::Config["assets.s3.bucket"],
                    :url => Radiant::Config["assets.url"] ? Radiant::Config["assets.url"] : "/:class/:id/:basename:no_original_style.:extension", 
                    :path => Radiant::Config["assets.path"] ? Radiant::Config["assets.path"] : ":rails_root/public/:class/:id/:basename:no_original_style.:extension"
                                 
  has_many :page_attachments, :dependent => :destroy
  has_many :pages, :through => :page_attachments
                                 
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  
  validates_attachment_presence :asset, :message => "You must choose a file to upload!"
  validates_attachment_content_type :asset, 
    :content_type => Radiant::Config["assets.content_types"].gsub(' ','').split(',') if Radiant::Config.table_exists? && Radiant::Config["assets.content_types"] && Radiant::Config["assets.skip_filetype_validation"] == nil
  validates_attachment_size :asset, 
    :less_than => Radiant::Config["assets.max_asset_size"].to_i.megabytes if Radiant::Config.table_exists? && Radiant::Config["assets.max_asset_size"]
    
  before_save :assign_title
    
  def thumbnail(size='original')
    case 
      when self.pdf?   : "/images/assets/pdf_#{size.to_s}.png"
      when self.movie? : "/images/assets/movie_#{size.to_s}.png"
      when self.audio? : "/images/assets/audio_#{size.to_s}.png"
      when self.other? : "/images/assets/doc_#{size.to_s}.png"
    else
      self.asset.url(size.to_sym)
    end
  end
  
  def generate_style(name, args={}) 
    size = args[:size] 
    format = args[:format] || :jpg
    asset = self.asset
    unless asset.exists?(name.to_sym)
      self.asset.styles[name.to_sym] = { :geometry => size, :format => format, :whiny => true, :convert_options => "", :processors => [:thumbnail] } 
      self.asset.reprocess!
    end
  end
  
  def basename
    File.basename(asset_file_name, ".*") if asset_file_name
  end
  
  def extension
    asset_file_name.split('.').last.downcase if asset_file_name
  end
  
  [:movie, :audio, :image, :other, :pdf].each do |content|
    define_method("#{content}?") { self.class.send("#{content}?", asset_content_type) }
  end
  
  def dimensions(size='original')
    @dimensions ||= {}
    @dimensions[size] ||= image? && begin
      image_file = self.path(size)
      image_size = ImageSize.new(open(image_file).read)
      [image_size.get_width, image_size.get_height]
    rescue
      [0, 0]
    end
  end
  
  def width(size='original')
    image? && self.dimensions(size)[0]
  end
  
  def height(size='original')
    image? && self.dimensions(size)[1]
  end
  
  def self.search(search, filter, page)  
    unless search.blank?

      search_cond_sql = []
      search_cond_sql << 'LOWER(asset_file_name) LIKE (:term)'
      search_cond_sql << 'LOWER(title) LIKE (:term)'
      search_cond_sql << 'LOWER(caption) LIKE (:term)'

      cond_sql = search_cond_sql.join(" or ")
    
      @conditions = [cond_sql, {:term => "%#{search.downcase}%" }]
    else
      @conditions = []
    end
    
    options = { :conditions => @conditions,
                :order => 'created_at DESC',
                :page => page,
                :per_page => 10 }
    
    @file_types = filter.blank? ? [] : filter.keys
    if not @file_types.empty?
      options[:total_entries] = count_by_conditions
      Asset.paginate_by_content_types(@file_types, :all, options )
    else
      Asset.paginate(:all, options)
    end
  end
  
  def self.count_by_conditions()
    type_conditions = @file_types.blank? ? nil : Asset.types_to_conditions(@file_types.dup).join(" OR ")
    @count_by_conditions ||= @conditions.empty? ? Asset.count(:all, :conditions => type_conditions) : Asset.count(:all, :conditions => @conditions)
  end  
  
  # used for extra mime types that do not follow the convention
  @@image_content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']
  @@extra_content_types = { :audio => ['application/ogg'], 
                            :movie => ['application/x-shockwave-flash'], 
                            :pdf => ['application/pdf'] }.freeze
  cattr_reader :extra_content_types, :image_content_types

  # use #send due to a ruby 1.8.2 issue
  @@image_condition = send(:sanitize_sql, ['asset_content_type IN (?)', image_content_types]).freeze
  @@movie_condition = send(:sanitize_sql, ['asset_content_type LIKE ? OR asset_content_type IN (?)', 'video%', extra_content_types[:movie]]).freeze
  @@audio_condition = send(:sanitize_sql, ['asset_content_type LIKE ? OR asset_content_type IN (?)', 'audio%', extra_content_types[:audio]]).freeze
  
  @@other_condition = send(:sanitize_sql, [
    'asset_content_type NOT LIKE ? AND asset_content_type NOT LIKE ? AND asset_content_type NOT IN (?)',
    'audio%', 'video%', (extra_content_types[:movie] + extra_content_types[:audio] + image_content_types)]).freeze
  cattr_reader *%w(movie audio image other).collect! { |t| "#{t}_condition".to_sym }
  
  %w(movie audio image other).each do |type|
    named_scope type.pluralize.intern, :conditions => self.send("#{type}_condition".intern)
  end
  
  private
  
    def assign_title
      self.title = basename if title.blank?
    end
    
end
