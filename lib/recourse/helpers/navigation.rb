module Recourse
  module Helpers
    # Helpers for the navbar and the sidebar.
    module Navigation
      # Trail to the current page as [title, path] pairs; a nil path is this page.
      def resource_breadcrumbs
        leaf = breadcrumb_leaf
        here = controller.controller_path
        return [[here, resources_name, nil]] unless leaf

        [[here, resources_name, url_for(action: :index)], [nil, leaf, nil]]
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

      # Label for a link to a resource: the icon its model picked, then its title,
      # with the letter at `key` marked where the link answers to one.
      def resource_label(resource, title, key = nil)
        name = key ? shortcut_title(title, key) : title

        safe_join [tag.i(class: "bi bi-#{Recourse.icon resource}"), name], ' '
      end

      # Sidebar entries as [name, title, path, key], in the order routes.rb declares
      # them, `key` being where in the title the letter that reaches it sits.
      def sidebar_resources
        taken = []

        Recourse.declared.filter_map do |path|
          next unless routed? path, 'index'

          title = path.split('/').last.humanize
          [
            path, title, url_for(controller: "/#{path}", action: :index),
            shortcut_index(title, taken),
          ]
        end
      end

      # True when a sidebar entry names the page being shown. The whole path, so a
      # namespaced resource and its top-level twin are not each other.
      def current_resource?(path)
        path == controller.controller_path
      end

    private

      # Only a page beneath the index names itself, and names what it is showing.
      def breadcrumb_leaf
        case controller.action_name
        when 'new', 'create' then t 'recourse.new', model: resource_name
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
