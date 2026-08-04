module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    # Draws what `resources` draws, after supplying any controller the host lacks.
    def recourses(*names, **, &)
      names.each { |name| Controllers.define_missing name }
      resources(*names, **, &)
    end
  end
end
