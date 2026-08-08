require_relative 'helpers/cells'
require_relative 'helpers/comboboxes'
require_relative 'helpers/constraints'
require_relative 'helpers/examples'
require_relative 'helpers/fields'
require_relative 'helpers/filters'
require_relative 'helpers/navigation'
require_relative 'helpers/references'
require_relative 'helpers/searches'
require_relative 'helpers/shortcuts'

module Recourse
  # View helpers for the pages the gem renders, and what the parts share.
  module Helpers
    include Cells, Comboboxes, Constraints, Examples, Fields, Filters, Navigation,
            References, Searches, Shortcuts

    # Bootstrap theme for each flash key, so a notice and an alert read apart.
    FLASH_THEMES = { 'notice' => 'theme-success', 'alert' => 'theme-danger' }

    # Theme for one flash entry, falling back to a neutral one for a host's key.
    def flash_theme(key)
      FLASH_THEMES.fetch key.to_s, 'theme-primary'
    end

    # Human, plural name of the resource on the page, e.g. 'Contacts'.
    def resources_name
      controller.controller_name.humanize
    end

    # Singular, lowercase name of the resource, e.g. 'contact'.
    def resource_name
      controller.controller_name.singularize.humanize.downcase
    end

    # Local name a row partial receives its record under, e.g. :contact.
    def resource_key
      controller.controller_name.singularize.to_sym
    end

    # The record the action built, read from the assigns rather than by ivar name.
    def resource_record
      controller.view_assigns[resource_key.to_s]
    end

    # What the record on the page is called, by whatever its model labels it with.
    def resource_record_label
      resource_record.attributes[resource_model.recourse_label.to_s]
    end

  private

    # `?q=anything` arrives as a String, which has no parameters to read.
    def query_params
      params[:q].respond_to?(:dig) ? params[:q] : {}
    end

    def resource_model
      controller.controller_name.classify.constantize
    end

    def routed?(controller_path, action)
      Rails.application.routes.routes.any? do |route|
        route.defaults[:controller] == controller_path &&
          route.defaults[:action] == action
      end
    end
  end
end
