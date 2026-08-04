module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    # Draws what `resources` draws, after supplying any controller the host lacks.
    def recourses(*names, **, &)
      names.each do |name|
        Recourse.declare name
        Controllers.define_missing name
      end

      resources(*names, **, &)
    end
  end
end
