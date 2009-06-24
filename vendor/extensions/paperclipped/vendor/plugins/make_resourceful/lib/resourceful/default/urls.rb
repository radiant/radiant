module Resourceful
  module Default
    # This file contains various methods to make URL helpers less painful.
    # They provide methods analogous to the standard foo_url and foo_path helpers.
    # However, they use make_resourceful's knowledge of the structure of the controller
    # to allow you to avoid figuring out which method to call and which parent objects it should be passed.
    module URLs
      # This returns the path for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController the following are equivalent:
      #
      #   object_path    #=> "/hats/12"
      #   hat_path(@hat) #=> "/hats/12"
      # 
      def object_path(object = current_object); object_route(object, 'path'); end
      # Same as object_path, but with the protocol and hostname.
      def object_url (object = current_object); object_route(object, 'url');  end

      # This is the same as object_path,
      # unless a parent exists.
      # Then it returns the nested path for the object.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   nested_object_path             #=> "/person/42/hats/12"
      #   person_hat_path(@person, @hat) #=> "/person/42/hats/12"
      # 
      def nested_object_path(object = current_object); nested_object_route(object, 'path'); end
      # Same as nested_object_path, but with the protocol and hostname.
      def nested_object_url (object = current_object); nested_object_route(object, 'url');  end

      # This returns the path for the edit action for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController the following are equivalent:
      #
      #   edit_object_path                    #=> "/hats/12/edit"
      #   edit_person_hat_path(@person, @hat) #=> "/hats/12/edit"
      # 
      def edit_object_path(object = current_object); edit_object_route(object, 'path'); end
      # Same as edit_object_path, but with the protocol and hostname.
      def edit_object_url (object = current_object); edit_object_route(object, 'url');  end

      # This returns the path for the collection of the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   objects_path              #=> "/people/42/hats"
      #   person_hats_path(@person) #=> "/people/42/hats"
      # 
      def objects_path; objects_route('path'); end
      # Same as objects_path, but with the protocol and hostname.
      def objects_url ; objects_route('url');  end

      # This returns the path for the new action for the current controller.
      # For example, in HatsController where Person has_many :hats and <tt>params[:person_id] == 42</tt>,
      # the following are equivalent:
      #
      #   new_object_path              #=> "/people/42/hats/new"
      #   new_person_hat_path(@person) #=> "/people/42/hats/new"
      # 
      def new_object_path; new_object_route('path'); end
      # Same as new_object_path, but with the protocol and hostname.
      def new_object_url ; new_object_route('url');  end

      # This returns the path for the parent object.
      # 
      def parent_path(object = parent_object)
        instance_route(parent_name, object, 'path')
      end
      # Same as parent_path, but with the protocol and hostname.
      def parent_url(object = parent_object)
        instance_route(parent_name, object, 'url')
      end

      # This prefix is added to the Rails URL helper names
      # before they're called.
      # By default, it's the underscored list of namespaces of the current controller,
      # or nil if there are no namespaces defined.
      # However, it can be overridden if another prefix is needed.
      # Note that if this is overridden,
      # the new method should return a string ending in an underscore.
      #
      # For example, in Admin::Content::PagesController:
      #
      #   url_helper_prefix #=> "admin_content_"
      #
      # Then object_path is the same as <tt>admin_content_page_path(current_object)</tt>.
      def url_helper_prefix
        namespaces.empty? ? nil : "#{namespaces.join('_')}_"
      end

      # This prefix is added to the Rails URL helper names
      # for the make_resourceful collection URL helpers,
      # objects_path and new_object_path.
      # It's only added if url_helper_prefix returns nil.
      # By default, it's the parent name followed by an underscore if a parent is given,
      # and the empty string otherwise.
      #
      # See also url_helper_prefix.
      def collection_url_prefix
        parent? ? "#{parent_name}_" : ''
      end

      private

      def object_route(object, type)
        instance_route(current_model_name.underscore, object, type)
      end

      def nested_object_route(object, type)
        return object_route(object, type) unless parent?
        send("#{url_helper_prefix}#{parent_name}_#{current_model_name.underscore}_#{type}", parent_object, object)
      end

      def edit_object_route(object, type)
        instance_route(current_model_name.underscore, object, type, "edit")
      end

      def objects_route(type)
        collection_route(current_model_name.pluralize.underscore, type)
      end

      def new_object_route(type)
        collection_route(current_model_name.underscore, type, "new")
      end

      def instance_route(name, object, type, action = nil)
        send("#{action ? action + '_' : ''}#{url_helper_prefix}#{name}_#{type}", object)
      end

      def collection_route(name, type, action = nil)
        send("#{action ? action + '_' : ''}#{url_helper_prefix || collection_url_prefix}#{name}_#{type}",
             *(parent? ? [parent_object] : []))
      end
    end
  end
end
