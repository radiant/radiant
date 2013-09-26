require 'acts_as_tree'
require 'annotatable'
require 'radiant/extension'

class Page < ActiveRecord::Base

  class MissingRootPageError < StandardError
    def initialize(message = 'Database missing root page'); super end
  end

  attr_accessible :lock_version, :parent_id, :class_name, :title, :slug, :breadcrumb, :layout_id, :status_id, :published_at, :parts_attributes

  # Callbacks
  before_save :update_virtual, :update_status, :set_allowed_children_cache

  # Associations
  acts_as_tree :order => 'virtual DESC, title ASC'
  has_many :parts, -> { order('id') }, :class_name => 'PagePart', :dependent => :destroy
  accepts_nested_attributes_for :parts, :allow_destroy => true
  has_many :fields, -> { order('id') }, :class_name => 'PageField', :dependent => :destroy
  accepts_nested_attributes_for :fields, :allow_destroy => true
  belongs_to :layout
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  # Validations
  validates :title, presence: true,
                    length: { maximum: 255 }
  validates :slug, presence: true,
                  length: { maximum: 100 },
                  format: %r{\A([-_.A-Za-z0-9]*|/)\z},
                  uniqueness: { scope: :parent_id }

  validates :breadcrumb, presence: true,
                        length: { maximum: 160 }

  validates :status_id, presence: true

  validate :valid_class_name

  include Radiant::Taggable
  include StandardTags
  include Annotatable

  annotate :description
  attr_accessor :request, :response, :pagination_parameters
  class_attribute :default_child
  self.default_child = self

  self.inheritance_column = 'class_name'

  def layout_with_inheritance
    unless layout_without_inheritance
      parent.layout if parent?
    else
      layout_without_inheritance
    end
  end
  alias_method_chain :layout, :inheritance

  def description
    self["description"]
  end

  def description=(value)
    self["description"] = value
  end

  def cache?
    true
  end

  def child_path(child)
    clean_path(path + '/' + child.slug)
  end
  alias_method :child_url, :child_path

  def part(name)
    if new_record? or parts.to_a.any?(&:new_record?)
      parts.to_a.find {|p| p.name == name.to_s }
    else
      parts.find_by_name name.to_s
    end
  end

  def has_part?(name)
    !part(name).nil?
  end

  def has_or_inherits_part?(name)
    has_part?(name) || inherits_part?(name)
  end

  def inherits_part?(name)
    !has_part?(name) && self.ancestors.any? { |page| page.has_part?(name) }
  end

  def field(name)
    if new_record? or fields.any?(&:new_record?)
      fields.detect { |f| f.name.downcase == name.to_s.downcase }
    else
      fields.find_by_name name.to_s
    end
  end

  def published?
    status == Status[:published]
  end

  def scheduled?
    status == Status[:scheduled]
  end

  def status
   Status.find(self.status_id)
  end

  def status=(value)
    self.status_id = value.id
  end

  def path
    if parent?
      parent.child_path(self)
    else
      clean_path(slug)
    end
  end
  alias_method :url, :path

  def process(request, response)
    @request, @response = request, response
    set_response_headers(@response)
    @response.body = render
    @response.status = response_code
  end

  def headers
    # Return a blank hash that child classes can override or merge
    { }
  end

  def set_response_headers(response)
    set_content_type(response)
    headers.each { |k,v| response.headers[k] = v }
  end
  private :set_response_headers

  def set_content_type(response)
    if layout
      content_type = layout.content_type.to_s.strip
      if content_type.present?
        response.headers['Content-Type'] = content_type
      end
    end
  end
  private :set_content_type

  def response_code
    200
  end

  def render
    if layout
      parse_object(layout)
    else
      render_part(:body)
    end
  end

  def render_part(part_name)
    part = part(part_name)
    if part
      parse_object(part)
    else
      ''
    end
  end

  def render_snippet(snippet)
    parse_object(snippet)
  end

  def find_by_path(path, live = true, clean = true)
    return nil if virtual?
    path = clean_path(path) if clean
    my_path = self.path
    if (my_path == path) && (!live or published?)
      self
    elsif (path =~ /^#{Regexp.quote(my_path)}([^\/]*)/)
      slug_child = children.where(slug: $1).first
      if slug_child
        found = slug_child.find_by_path(path, live, clean)
        return found if found
      end
      children.each do |child|
        found = child.find_by_path(path, live, clean)
        return found if found
      end

      if live
        file_not_found_names = ([FileNotFoundPage] + FileNotFoundPage.descendants).map(&:name)
        children.where(status_id: Status[:published].id).where(class_name: file_not_found_names).first
      else
        children.first
      end
    end
  end

  def update_status
    self.published_at = Time.zone.now if published? && self.published_at == nil

    if self.published_at != nil && (published? || scheduled?)
      self[:status_id] = Status[:scheduled].id if self.published_at  > Time.zone.now
      self[:status_id] = Status[:published].id if self.published_at <= Time.zone.now
    end

    true
  end

  def to_xml(options={}, &block)
    super(options.reverse_merge(:include => :parts), &block)
  end

  def default_child
    self.class.default_child
  end

  def allowed_children_lookup
    [default_child, *Page.descendants.sort_by(&:name)].uniq
  end

  def set_allowed_children_cache
    self.allowed_children_cache = allowed_children_lookup.collect(&:name).join(',')
  end

  class << self

    def root
      find_by_parent_id(nil)
    end

    def find_by_path(path, live = true)
      raise MissingRootPageError unless root
      root.find_by_path(path, live)
    end

    def date_column_names
      self.columns.collect{|c| c.name if c.sql_type =~ /(date|time)/}.compact
    end

    def display_name(string = nil)
      if string
        @display_name = string
      else
        @display_name ||= begin
          n = name.to_s
          n.sub!(/^(.+?)Page$/, '\1')
          n.gsub!(/([A-Z])/, ' \1')
          n.strip
        end
      end
      @display_name = @display_name + " - not installed" if missing? && @display_name !~ /not installed/
      @display_name
    end

    def display_name=(string)
      display_name(string)
    end

    def load_subclasses
      ([Radiant.root] + Radiant::Extension.descendants.map(&:root)).each do |path|
        Dir["#{path}/app/models/*_page.rb"].each do |page|
          $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
        end
      end
      if ActiveRecord::Base.connection.tables.include?('pages') && Page.column_names.include?('class_name') # Assume that we have bootstrapped
        Page.connection.select_values("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL").each do |p|
          begin
            p.constantize
          rescue NameError, LoadError
            eval(%Q{class #{p} < Page; acts_as_tree; def self.missing?; true end end}, TOPLEVEL_BINDING)
          end
        end
      end
    end

    def new_with_defaults(config = Radiant::Config)
      page = new
      page.parts.concat default_page_parts(config)
      page.fields.concat default_page_fields(config)
      default_status = config['defaults.page.status']
      page.status = Status[default_status] if default_status
      page
    end

    def is_descendant_class_name?(class_name)
      (Page.descendants.map(&:to_s) + [nil, "", "Page"]).include?(class_name)
    end

    def descendant_class(class_name)
      raise ArgumentError.new("argument must be a valid descendant of Page") unless is_descendant_class_name?(class_name)
      if ["", nil, "Page"].include?(class_name)
        Page
      else
        class_name.constantize
      end
    end

    def missing?
      false
    end

    private

      def default_page_parts(config = Radiant::Config)
        default_parts = config['defaults.page.parts'].to_s.strip.split(/\s*,\s*/)
        default_parts.map do |name|
          PagePart.new(:name => name, :filter_id => config['defaults.page.filter'])
        end
      end

      def default_page_fields(config = Radiant::Config)
        default_fields = config['defaults.page.fields'].to_s.strip.split(/\s*,\s*/)
        default_fields.map do |name|
          PageField.new(:name => name)
        end
      end
  end

  private

    def valid_class_name
      unless Page.is_descendant_class_name?(class_name)
        errors.add :class_name, "must be set to a valid descendant of Page"
      end
    end

    def attributes_protected_by_default
      super - [self.class.inheritance_column]
    end

    def update_virtual
      unless self.class == Page.descendant_class(class_name)
        self.virtual = Page.descendant_class(class_name).new.virtual?
      else
        self.virtual = virtual?
      end
      true
    end

    def clean_path(path)
      "/#{ path.to_s.strip }/".gsub(%r{//+}, '/')
    end
    alias_method :clean_url, :clean_path

    def parent?
      !parent.nil?
    end

    def lazy_initialize_parser_and_context
      unless @parser and @context
        @context = PageContext.new(self)
        @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
      end
      @parser
    end

    def parse(text)
      lazy_initialize_parser_and_context.parse(text)
    end

    def parse_object(object)
      text = object.content || ''
      text = parse(text)
      text = object.filter.filter(text) if object.respond_to? :filter_id
      text
    end

end
