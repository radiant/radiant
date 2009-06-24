module Resourceful
  module Default
    module Responses
      # Sets the default flash message.
      # This message can be overridden by passing in
      # an HTTP parameter of the form "_flash[type]" via POST or GET.
      # _flash HTTP parameter values will be HTML escaped prior to 
      # being used.
      #
      # You can use this to easily have multiple forms
      # post to the same create/edit/destroy actions
      # but display different flash notices -
      # without modifying the controller code at all.
      #
      # By default, the flash types are +notice+ when the database operation completes successfully
      # and +error+ when it fails.
      #
      #--
      # TODO: Move this out of here
      #++
      def set_default_flash(type, message)
        flash[type] ||= (params[:_flash] && params[:_flash][type]) ? 
          ERB::Util.h(params[:_flash][type]) : 
          message
      end

      # Sets the default redirect
      # (the argument passed to +redirect_to+).
      # This message can be overridden by passing in
      # an HTTP parameter of the form "_redirect_on[status]" via POST or GET.
      #
      # You can use this to easily have multiple forms
      # post to the same create/edit/destroy actions
      # but redirect to different URLs -
      # without modifying the controller code at all.
      #
      # By default, the redirect statuses are +success+ when the database operation completes successfully
      # and +failure+ when it fails.
      # Use the <tt>:status</tt> option to specify which status to run the redirect for.
      # For example:
      #
      #   set_default_redirect "/posts", :status => :failure
      #
      # This will run <tt>redirect_to params[:_redirect_on][:failure]</tt> if the parameter exists,
      # or <tt>redirect_to "/posts"</tt> otherwise.
      #
      #--
      # TODO: Move this out of here
      #++
      def set_default_redirect(to, options = {})
        status = options[:status] || :success
        redirect_to (params[:_redirect_on] && params[:_redirect_on][status]) || to
      end

      # This method is automatically run when this module is included in Resourceful::Base.
      # It sets up the default responses for the default actions.
      def self.included(base)
        base.made_resourceful do
          response_for(:show, :index, :edit, :new) do |format|
            format.html
            format.js
          end

          response_for(:show_fails) do |format|
            not_found = Proc.new { render :text => "No item found", :status => 404 }
            format.html &not_found
            format.js &not_found
            format.xml &not_found
          end

          response_for(:create) do |format|
            format.html do
              set_default_flash(:notice, "Create successful!")
              set_default_redirect object_path
            end
            format.js
          end
          
          response_for(:create_fails) do |format|
            format.html do
              set_default_flash :error, "There was a problem!"
              render :action => :new, :status => 422
            end
            format.js
          end
        
          response_for(:update) do |format|
            format.html do
              set_default_flash :notice, "Save successful!"
              set_default_redirect object_path
            end
            format.js
          end
          
          response_for(:update_fails) do |format|
            format.html do
              set_default_flash :error, "There was a problem saving!"
              render :action => :edit, :status => 422
            end
            format.js
          end
          
          response_for(:destroy) do |format|
            format.html do
              set_default_flash :notice, "Record deleted!"
              set_default_redirect objects_path
            end
            format.js
          end
          
          response_for(:destroy_fails) do |format|
            format.html do
              set_default_flash :error, "There was a problem deleting!"
              set_default_redirect :back, :status => :failure
            end
            format.js
          end
        end
      end
    end
  end
end
