module Recourse
  # Defines the controller classes a host app has not written for itself.
  module Controllers
    # Creates a controller for the named resource unless the host app has one.
    def self.define_missing(name)
      class_name = "#{name.to_s.camelize}Controller"
      # const_defined? is already true for a Zeitwerk autoload, so a host
      # controller that exists only as a file on disk is never shadowed.
      return if Object.const_defined?(class_name)

      Object.const_set(class_name, Class.new(ResourcesController))
    end
  end
end
