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

        turbo_link_to tag.i(class: 'bi bi-pencil-square'), path, aria: { label: 'Edit' }
      end

      # A link out of a table. Every cell is inside the results frame, and the page a
      # cell links to has no frame of that name, so Turbo would replace the table with
      # `Content missing` rather than leaving the page. `_top` is what leaves it.
      # Takes everything `link_to` takes, and a `data:` of its own still wins.
      def turbo_link_to(name, path, **options)
        data = { turbo_frame: '_top' }.merge options.fetch(:data, {})

        link_to name, path, **options, data: data
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
