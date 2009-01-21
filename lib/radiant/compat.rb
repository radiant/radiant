# TODO: Remove this after upgrading to Rails 2.2+
unless '1.9'.respond_to?(:force_encoding)
 String.class_eval do
   begin
     remove_method :chars
   rescue NameError
     # OK
   end
 end
end