module Recourse
  # View helpers for the pages the gem renders.
  module Helpers
    # Human, plural name of the resource on the page, e.g. 'Contacts'.
    def resources_name
      controller.controller_name.humanize
    end
  end
end
