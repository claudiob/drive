module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    # Draws what `resources` draws, after supplying any controller the host lacks. A
    # block nests what it declares under each resource — ZIPs at
    # `/counties/:county_id/zips` — with the nested controller namespaced after the
    # parent, so it and the top-level `ZIPsController` stay two controllers.
    def recourses(*names, **, &block)
      names.each do |name|
        # `@scope[:module]` is the namespace being drawn in, so a resource is declared
        # and its controller defined under the path Rails will route to.
        path = [@scope[:module], name].compact.join '/'
        # A nested resource is reached through a row of its parent's index, so the
        # sidebar gets no entry for it.
        Recourse.declare path unless @scope[:scope_level_resource]
        Controllers.define_missing path
      end

      return resources(*names, **) unless block

      resources(*names, **) do
        scope module: @scope[:scope_level_resource].name, &block
      end
    end
  end
end
