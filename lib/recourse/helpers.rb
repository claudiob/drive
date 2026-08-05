require_relative 'helpers/cells'
require_relative 'helpers/fields'
require_relative 'helpers/navigation'

module Recourse
  # View helpers for the pages the gem renders, and what the parts share.
  module Helpers
    include Cells, Fields, Navigation

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

  private

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
