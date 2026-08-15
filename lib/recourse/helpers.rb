require_relative 'helpers/actions'
require_relative 'helpers/cards'
require_relative 'helpers/cells'
require_relative 'helpers/colors'
require_relative 'helpers/comboboxes'
require_relative 'helpers/constraints'
require_relative 'helpers/counters'
require_relative 'helpers/deletions'
require_relative 'helpers/examples'
require_relative 'helpers/fields'
require_relative 'helpers/filters'
require_relative 'helpers/formats'
require_relative 'helpers/inputs'
require_relative 'helpers/kinds'
require_relative 'helpers/navigation'
require_relative 'helpers/parents'
require_relative 'helpers/references'
require_relative 'helpers/refreshes'
require_relative 'helpers/routing'
require_relative 'helpers/rows'
require_relative 'helpers/searches'
require_relative 'helpers/shortcuts'
require_relative 'helpers/sorts'
require_relative 'helpers/values'

module Recourse
  # View helpers for the pages the gem renders, and what the parts share.
  module Helpers
    include Actions, Cards, Cells, Colors, Comboboxes, Constraints, Counters,
            Deletions, Examples, Fields, Filters, Formats, Inputs, Kinds, Navigation,
            Parents, References, Refreshes, Routing, Rows, Searches, Shortcuts,
            Sorts, Values

    # The grid a record's own two pages lay an attribute out in: two columns on a large
    # viewport, and the same padding on both, so a value and the field that edits it sit
    # at the same height whichever page is open. The rule between rows belongs to the
    # show page alone — `.recourse-values` in the layout draws it.
    ROW = 'recourse-row pb-2 mb-3 lg:col-6'

    # Bootstrap theme for each flash key, so a notice and an alert read apart.
    FLASH_THEMES = { 'notice' => 'theme-success', 'alert' => 'theme-danger' }

    # Theme for one flash entry, falling back to a neutral one for a host's key.
    def flash_theme(key)
      FLASH_THEMES.fetch key.to_s, 'theme-primary'
    end

    # Human, plural name of the resource on the page, e.g. 'Contacts'.
    def resources_name
      Recourse.title controller.controller_name
    end

    # Singular, lowercase name of the resource, e.g. 'contact'.
    def resource_name
      Recourse.downcase resource_model.model_name.human
    end

    # Local name a row partial receives its record under, e.g. :contact.
    def resource_key
      controller.controller_name.singularize.to_sym
    end

    # The record the action built, read from the assigns rather than by ivar name.
    def resource_record
      controller_assign resource_key.to_s
    end

    # The one door to what the controller assigned. `view_assigns` is public API,
    # and every name the gem reads through it walks this method, so the untyped
    # contract with the controller's ivar names has a single seam.
    def controller_assign(name)
      controller.view_assigns[name]
    end

    # What the record on the page is called, by whatever its model labels it with.
    def resource_record_label
      resource_record.attributes[resource_model.recourse_label.to_s]
    end

  private

    # `?q=anything` arrives as a String, which has no parameters to read — the
    # same test `Recourse::Search` makes, spelled the same way.
    def query_params
      params[:q].is_a?(ActionController::Parameters) ? params[:q] : {}
    end

    def resource_model
      Recourse.model controller.controller_name
    end
  end
end
