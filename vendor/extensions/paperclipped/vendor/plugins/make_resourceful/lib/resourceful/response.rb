module Resourceful
  # This is the class of the object passed to the Builder#response_for method.
  # It shouldn't be used by users.
  #
  # The Response collects format procs
  # and returns them with the format method,
  # in the order they were given.
  # For example:
  #
  #   response.html { redirect_to '/' }
  #   response.xml { render :xml => current_object.to_xml }
  #   response.js
  #   response.formats #=> [[:html, #<Proc>], [:xml, #<Proc>], [:js, #<Proc>]]
  #
  # Note that the <tt>:js</tt> response is the empty proc -
  # the same as <tt>proc {}</tt>.
  class Response # :nodoc:
    # Returns a list of pairs of formats and procs
    # representing the formats passed to the response object.
    # See class description.
    attr :formats

    # Returns a new Response with no format data.
    def initialize
      @formats = []
    end

    # Used to dispatch the individual format methods.
    def method_missing(name, &block)
      @formats.push([name, block || proc {}]) unless @formats.any? {|n,b| n == name}
    end
  end
end
