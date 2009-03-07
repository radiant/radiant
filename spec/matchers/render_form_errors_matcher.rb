module Spec
  module Rails
    module Matchers
      
      class RenderFormErrors
        def initialize(error_fields, example)
          @error_fields, @example = error_fields, example
        end
        
        def matches?(response)
          begin
            response.should @example.have_tag('#error')
          rescue
            @display_failure_message = 'Expected to display form errors but did not'
          end
          
          unless @display_failure_message
            @error_fields.to_fields.each do |field_name, error_message|
              begin
                @example.assert_tag(
                  :tag => 'div',
                  :attributes => {:class => 'error-with-field'},
                  :child => {
                    :tag => /input|select|textarea/,
                    :attributes => {:name => field_name}
                  },
                  :child => {
                    :tag => 'small',
                    :attributes => {:class => 'error'},
                    :content => error_message
                  }
                )
              rescue
                @error_field_failure_message = "Expected field #{field_name} to have error message '#{error_message}' but did not"
                break
              end
            end
          end
          
          @display_failure_message.nil? && @error_field_failure_message.nil?
        end
        
        def failure_message
          @display_failure_message ? @display_failure_message : @error_field_failure_message
        end
        
        def negative_failure_message
          'Expected not to display form errors but did'
        end
      end
      
      # Used to ensure that there are model errors shown on the page.
      #
      # Looks to see if the response includes content according to the
      # application's technique for displaying form errors.
      def render_form_errors(error_fields = {})
        RenderFormErrors.new(error_fields, self)
      end
      
    end
  end
end