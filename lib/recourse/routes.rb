module Recourse
  # Extends the config/routes.rb DSL, so `recourses` is available anywhere
  # `resources` is.
  module Routes
    # Module the controllers are looked up in, keeping them clear of any
    # same-named controller the host app already has.
    CONTROLLER_MODULE = :administered

    # Draws everything `resources` draws, at the same paths, but pointing at
    # the controllers this gem provides rather than the host app's own.
    def recourses(*names, **options, &block)
      scope(module: CONTROLLER_MODULE) do
        resources(*names, **options, &block)
      end
    end
  end
end
