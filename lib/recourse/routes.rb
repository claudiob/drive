module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    # Draws what `resources` draws, after supplying any controller the host lacks.
    def recourses(*names, **, &)
      names.each do |name|
        # `@scope[:module]` is the namespace being drawn in, so a resource is declared
        # and its controller defined under the path Rails will route to.
        path = [@scope[:module], name].compact.join '/'
        Recourse.declare path
        Controllers.define_missing path
      end

      resources(*names, **, &)
    end
  end
end
