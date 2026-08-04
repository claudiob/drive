module Recourse
  # Defines the controller classes a host app has not written for itself.
  module Controllers
    # Creates a controller for the named resource unless the host app has one.
    def self.define_missing(name)
      class_name = "#{name.to_s.camelize}Controller"
      # const_defined? is true for a Zeitwerk autoload, so files on disk count too.
      return if Object.const_defined?(class_name)

      Object.const_set(class_name, Class.new(RecoursesController))
    end
  end
end
