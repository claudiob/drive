module Recourse
  # View helpers for the pages the gem renders.
  module Helpers
    # How a time reads on a page, e.g. 'Aug 4 at 03:47pm EDT'.
    TIME_FORMAT = '%b %-d at %I:%M%P %Z'

    # Human, plural name of the resource on the page, e.g. 'Contacts'.
    def resources_name
      controller.controller_name.humanize
    end

    # Singular, lowercase name of the resource, e.g. 'contact'.
    def resource_name
      controller.controller_name.singularize.humanize.downcase
    end

    # Trail to the current page as [title, path] pairs; a nil path is this page.
    def resource_breadcrumbs
      return [[resources_name, nil]] unless controller.action_name == 'new'

      [[resources_name, url_for(action: :index)], ["New #{resource_name}", nil]]
    end

    # Path to this resource's new page, or nil when there is not one to link to.
    def new_resource_path
      return unless controller.class.action_methods.include? 'new'
      return unless routed? controller.controller_path, 'new'

      url_for action: :new
    end

    # Label for a link to a resource: its icon, then its title.
    def resource_label(title)
      icon = NAVIGATION_ICONS.fetch title, FALLBACK_ICON

      safe_join [tag.i(class: "bi bi-#{icon}"), title], ' '
    end

    # Sidebar entries as [name, title, path], in the order routes.rb declares them.
    def sidebar_resources
      Recourse.declared.filter_map do |name|
        next unless routed? name, 'index'

        [name, name.humanize, url_for(controller: "/#{name}", action: :index)]
      end
    end

    # True when a sidebar entry names the resource the page is showing.
    def current_resource?(name)
      name == controller.controller_name
    end

    # Columns the table shows: every attribute that is not encrypted.
    def resource_columns
      resource_model.column_names - Array(resource_model.encrypted_attributes).map(&:to_s)
    end

    # Heading for a column, which a host app can translate like any attribute.
    def resource_column_title(column)
      resource_model.human_attribute_name column
    end

    # Value for one cell, formatted according to what the column holds.
    def resource_cell(resource, column)
      value = resource.attributes[column]

      return time_tag value, value.strftime(TIME_FORMAT) if value.is_a? Time
      return number_to_phone value if column == 'phone'

      value
    end

    # One cell: a heading in the header row, a labelled value in every other.
    def column(header:, value: nil, heading: false, **)
      return tag.th(header, scope: :col, **) if heading

      tag.td(value, 'data-cell': header, **)
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
