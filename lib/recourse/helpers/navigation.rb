module Recourse
  module Helpers
    # Helpers for the navbar and the sidebar.
    module Navigation
      # Trail to the current page as [title, path] pairs; a nil path is this page.
      def resource_breadcrumbs
        leaf = breadcrumb_leaf
        return [[resources_name, nil]] unless leaf

        [[resources_name, url_for(action: :index)], [leaf, nil]]
      end

      # Pencil linking to a record's edit page, or nothing when there is not one.
      def edit_resource_link(record)
        path = edit_resource_path record
        return unless path

        # `_top` because the row is inside the results frame, which a form page
        # has none of: without it the edit page would be loaded into the table.
        link_to tag.i(class: 'bi bi-pencil-square'), path, aria: { label: 'Edit' },
                                                           data: { turbo_frame: '_top' }
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

    private

      # Only a page beneath the index names itself, and names what it is showing.
      def breadcrumb_leaf
        case controller.action_name
        when 'new', 'create' then "New #{resource_name}"
        when 'edit', 'update' then resource_record_label
        end
      end

      def edit_resource_path(record)
        return unless controller.class.action_methods.include? 'edit'
        return unless routed? controller.controller_path, 'edit'

        url_for action: :edit, id: record
      end
    end
  end
end
