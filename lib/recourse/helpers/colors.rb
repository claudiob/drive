module Recourse
  module Helpers
    # The primary colour, where a host has named one.
    module Colors
    private

      # The `:root` block that makes the primary colour primary, or nothing at all
      # where neither a colour nor a palette is set — the stylesheet's own blue is
      # already there, carrying the ink upstream chose for it. It wins on being later
      # rather than on being more specific, both selectors being `:root`, so it belongs
      # after the stylesheet link and never before it.
      def primary_color_style
        color = Recourse.primary_color
        return unless color

        render 'recourses/color', color: color, ink: Recourse.ink(color)
      end
    end
  end
end
