module Recourse
  module Helpers
    # The colour scheme, where a host has named one.
    module Themes
    private

      # The stylesheet that repaints Bootstrap's ramps in `Recourse.theme`, or nothing at
      # all where none is set — the stylesheet's own palette is already there. A file
      # rather than a block in the page: it is the same bytes on every request, so a
      # browser is asked for it once. After the Bootstrap link and never before it, both
      # blocks being `:root`, so it wins on being later.
      def theme_stylesheet_link
        theme = Recourse.theme
        return unless theme

        tag.link rel: 'stylesheet', href: "/recourse/themes/#{theme}.css"
      end
    end
  end
end
