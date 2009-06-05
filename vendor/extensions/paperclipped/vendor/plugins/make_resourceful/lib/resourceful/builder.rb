require 'resourceful/response'
require 'resourceful/serialize'
require 'resourceful/default/actions'

module Resourceful
  # The Maker#make_resourceful block is evaluated in the context
  # of an instance of this class.
  # It provides various methods for customizing the behavior of the actions
  # built by make_resourceful.
  #
  # All instance methods of this class are available in the +make_resourceful+ block.
  class Builder
    # The klass of the controller on which the builder is working.
    attr :controller, true

    # The constructor is only meant to be called internally.
    #
    # This takes the klass (class object) of a controller
    # and constructs a Builder ready to apply the make_resourceful
    # additions to the controller.
    def initialize(kontroller)
      @controller       = kontroller
      @inherited        = !kontroller.read_inheritable_attribute(:resourceful_responses).blank?
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      @callbacks        = {:before => {}, :after => {}}
      @responses        = {}
      @publish          = {}
      @parents          = []
    end

    # This method is only meant to be called internally.
    #
    # Applies all the changes that have been declared
    # via the instance methods of this Builder
    # to the kontroller passed in to the constructor.
    def apply
      apply_publish

      kontroller = @controller
      Resourceful::ACTIONS.each do |action_named|
        # See if this is a method listed by #actions
        unless @ok_actions.include? action_named
          # If its not listed, then remove the method
          # No one can hit it... if its DEAD!
          @action_module.send :remove_method, action_named
        end
      end

      kontroller.hidden_actions.reject! &@ok_actions.method(:include?)
      kontroller.send :include, @action_module

      kontroller.read_inheritable_attribute(:resourceful_callbacks).merge! @callbacks
      kontroller.read_inheritable_attribute(:resourceful_responses).merge! @responses
      kontroller.write_inheritable_attribute(:made_resourceful, true)

      kontroller.write_inheritable_attribute(:parents, @parents)
      kontroller.before_filter :load_parent_object, :only => @ok_actions
    end

    # :call-seq:
    #   actions(*available_actions)
    #   actions :all
    # 
    # Adds the default RESTful actions to the controller.
    #
    # If the only argument is <tt>:all</tt>,
    # adds all the actions listed in Resourceful::ACTIONS[link:classes/Resourceful.html]
    # (or Resourceful::SINGULAR_ACTIONS[link:classes/Resourceful.html]
    # for a singular controller).
    #
    # Otherwise, this adds all actions
    # whose names were passed as arguments.
    #
    # For example:
    #
    #   actions :show, :new, :create
    #
    # This adds the +show+, +new+, and +create+ actions
    # to the controller.
    #
    # The available actions are defined in Default::Actions.
    def actions(*available_actions)
      if available_actions.first == :all
        if controller.respond_to?(:new_without_capture)
          available_actions = controller.new_without_capture.plural? ? ACTIONS : SINGULAR_ACTIONS
        else
          available_actions = controller.new.plural? ? ACTIONS : SINGULAR_ACTIONS
        end
      end

      available_actions.each { |action| @ok_actions << action.to_sym }
    end
    alias build actions

    # :call-seq:
    #   before(*events) { ... }
    #
    # Sets up a block of code to run before one or more events.
    #
    # All the default actions can be used as +before+ events:
    # <tt>:index</tt>, <tt>:show</tt>, <tt>:create</tt>, <tt>:update</tt>, <tt>:new</tt>, <tt>:edit</tt>, and <tt>:destroy</tt>.
    #
    # +before+ events are run after any objects are loaded[link:classes/Resourceful/Default/Accessors.html#M000015],
    # but before any database operations or responses.
    #
    # For example:
    #
    #   before :show, :edit do
    #     @page_title = current_object.title
    #   end
    #
    # This will set the <tt>@page_title</tt> variable
    # to the current object's title
    # for the show and edit actions.
    def before(*events, &block)
      events.each do |event|
        @callbacks[:before][event.to_sym] = block
      end
    end

    # :call-seq:
    #   after(*events) { ... }
    #
    # Sets up a block of code to run after one or more events.
    #
    # There are two sorts of +after+ events.
    # <tt>:create</tt>, <tt>:update</tt>, and <tt>:destroy</tt>
    # are run after their respective database operations
    # have been completed successfully.
    # <tt>:create_fails</tt>, <tt>:update_fails</tt>, and <tt>:destroy_fails</tt>,
    # on the other hand,
    # are run after the database operations fail.
    #
    # +after+ events are run after the database operations
    # but before any responses.
    #
    # For example:
    #
    #   after :create_fails, :update_fails do
    #     current_object.password = nil
    #   end
    #
    # This will nillify the password of the current object
    # if the object creation/modification failed.
    def after(*events, &block)
      events.each do |event|
        @callbacks[:after][event.to_sym] = block
      end
    end

    # :call-seq:
    #   response_for(*actions) { ... }
    #   response_for(*actions) { |format| ... }
    #
    # Sets up a block of code to run
    # instead of the default responses for one or more events.
    #
    # If the block takes a format parameter,
    # it has the same semantics as Rails' +respond_to+ method.
    # Various format methods are called on the format object
    # with blocks that say what to do for each format.
    # For example:
    #
    #   response_for :index do |format|
    #     format.html
    #     format.atom do
    #       headers['Content-Type'] = 'application/atom+xml; charset=utf-8'
    #       render :action => 'atom', :layout => false
    #     end
    #   end
    #
    # This doesn't do anything special for the HTML
    # other than ensure that the proper view will be rendered,
    # but for ATOM it sets the proper content type
    # and renders the atom template.
    #
    # If you only need to set the HTML response,
    # you can omit the format parameter.
    # For example:
    #
    #   response_for :new do
    #     render :action => 'edit'
    #   end
    #
    # This is the same as
    #     
    #   response_for :new do |format|
    #     format.html { render :action => 'edit' }
    #   end
    #
    # The default responses are defined by
    # Default::Responses.included[link:classes/Resourceful/Default/Responses.html#M000011].
    def response_for(*actions, &block)
      raise "Must specify one or more actions for response_for." if actions.empty?

      if block.arity < 1
        response_for(*actions) do |format|
          format.html(&block)
        end
      else
        response = Response.new
        block.call response

        actions.each do |action|
          @responses[action.to_sym] = response.formats
        end
      end
    end

    # :call-seq:
    #   publish *formats, options = {}, :attributes => [ ... ]
    #
    # publish allows you to easily expose information about resourcess in a variety of formats.
    # The +formats+ parameter is a list of formats
    # in which to publish the resources.
    # The formats supported by default are +xml+, +yaml+, and +json+,
    # but other formats may be added by defining +to_format+ methods
    # for the Array and Hash classes
    # and registering the mime type with Rails' Mime::Type.register[http://api.rubyonrails.org/classes/Mime/Type.html#M001115].
    # See Resourceful::Serialize for more details..
    #
    # The <tt>:attributes</tt> option is mandatory.
    # It takes an array of attributes (as symbols) to make public.
    # These attributes can refer to any method on current_object;
    # they aren't limited to database fields.
    # For example:
    #
    #   # posts_controller.rb
    #   publish :yaml, :attributes => [:title, :created_at, :rendered_content]
    #
    # Then GET /posts/12.yaml would render
    #
    #   --- 
    #   post: 
    #     title: Cool Stuff
    #     rendered_content: |-
    #       <p>This is a post.</p>
    #       <p>It's about <strong>really</strong> cool stuff.</p>
    #     created_at: 2007-04-28 04:32:08 -07:00
    #
    # The <tt>:attributes</tt> array can even contain attributes
    # that are themselves models.
    # In this case, you must use a hash to specify their attributes as well.
    # For example:
    #
    #   # person_controller.rb
    #   publish :xml, :json, :attributes => [
    #     :name, :favorite_color, {
    #     :pet_cat => [:name, :breed],
    #     :hat => [:type]
    #   }]
    #
    # Then GET /people/18.xml would render
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <person>
    #     <name>Nathan</name>
    #     <favorite-color>blue</favorite_color>
    #     <pet-cat>
    #       <name>Jasmine</name>
    #       <breed>panther</breed>
    #     </pet-cat>
    #     <hat>
    #       <type>top</type>
    #     </hat>
    #   </person>
    #
    # publish will also allow the +index+ action
    # to render lists of objects.
    # An example would be too big,
    # but play with it a little on your own to see.
    #
    # publish takes only one optional option: <tt>only</tt>.
    # This specifies which action to publish the resources for.
    # By default, they're published for both +show+ and +index+.
    # For example:
    #
    #   # cats_controller.rb
    #   publish :json, :only => :index, :attributes => [:name, :breed]
    #
    # Then GET /cats.json would work, but GET /cats/294.json would fail.
    def publish(*formats)
      options = {
        :only => [:show, :index]
      }.merge(Hash === formats.last ? formats.pop : {})
      raise "Must specify :attributes option" unless options[:attributes]
      
      Array(options.delete(:only)).each do |action|
        @publish[action] ||= []
        formats.each do |format|
          format = format.to_sym
          @publish[action] << [format, proc do
            render_action = [:json, :xml].include?(format) ? format : :text
            render render_action => (plural_action? ? current_objects : current_object).serialize(format, options)
          end]
        end
      end
    end

    # Specifies parent resources for the current resource.
    # Each of these parents will be loaded automatically
    # if the proper id parameter is given.
    # For example,
    #
    #   # cake_controller.rb
    #   belongs_to :baker, :customer
    #
    # Then on GET /bakers/12/cakes,
    #
    #   params[:baker_id] #=> 12
    #   parent?           #=> true
    #   parent_name       #=> "baker"
    #   parent_model      #=> Baker
    #   parent_object     #=> Baker.find(12)
    #   current_objects   #=> Baker.find(12).cakes
    #
    def belongs_to(*parents)
      @parents = parents.map(&:to_s)
    end
    
    # This method is only meant to be called internally.
    #
    # Returns whether or not the Builder's controller
    # inherits make_resourceful settings from a parent controller.
    def inherited?
      @inherited
    end

    private
    
    def apply_publish
      @publish.each do |action, types|
        @responses[action.to_sym] ||= []
        @responses[action.to_sym] += types
      end
    end
  end
end
