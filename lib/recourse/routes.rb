module Recourse
  # Extends the config/routes.rb DSL, so `recourses` is available anywhere
  # `resources` is.
  module Routes
    # Draws everything `resources` draws, at the same paths and pointing at the
    # same controllers. The extra routes it adds on top come later.
    def recourses(...)
      resources(...)
    end
  end
end
