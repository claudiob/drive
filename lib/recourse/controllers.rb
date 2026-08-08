module Recourse
  # Defines the controller classes a host app has not written for itself.
  module Controllers
    # Creates a controller for the named resource unless the host app has one. The
    # name arrives with whatever namespace it was drawn in — `admin/contacts` — so
    # the constant lands where Rails will look for it.
    def self.define_missing(path)
      class_name = "#{path.camelize}Controller"
      # const_defined? is true for a Zeitwerk autoload, so files on disk count too.
      return if Object.const_defined? class_name

      namespace(class_name.deconstantize).const_set class_name.demodulize,
                                                    Class.new(RecoursesController)
    end

    # The module a namespaced controller belongs in, made where the host has none of
    # its own: `namespace :admin` draws routes whether or not an `Admin` exists.
    def self.namespace(name)
      name.split('::').reduce Object do |scope, part|
        next scope.const_get part, false if scope.const_defined? part, false

        scope.const_set part, Module.new
      end
    end
  end
end
