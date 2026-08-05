module Recourse
  module Helpers
    # Helpers for the navbar and the sidebar.
    module Navigation
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
    end
  end
end
