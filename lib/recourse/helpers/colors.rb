module Recourse
  module Helpers
    # The primary colour, where a host has named one.
    module Colors
      # The `:root` block that makes `Recourse.color` the primary one, or nothing at
      # all where no colour is set — the stylesheet's own blue is already there. It
      # wins on being later rather than on being more specific, both selectors being
      # `:root`, so it belongs after the stylesheet link and never before it.
      def primary_color_style
        color = Recourse.color
        return unless color

        render 'recourses/color', color: color
      end
    end
  end
end
