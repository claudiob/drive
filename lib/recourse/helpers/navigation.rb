module Recourse
  module Helpers
    # Helpers for the navbar and the sidebar.
    module Navigation
      # Trail to the current page as [resource, title, path] triples, opening with
      # the parent a nested page sits under; a nil path is not a link.
      def resource_breadcrumbs
        crumbs = parent_breadcrumbs
        leaf = breadcrumb_leaf
        here = controller.controller_path
        return crumbs << [here, resources_name, nil] unless leaf

        crumbs << [here, resources_name, url_for(action: :index)] << [nil, leaf, nil]
      end

      # A link out of a table. Every cell is inside the results frame, and the page a
      # cell links to has no frame of that name, so Turbo would replace the table with
      # `Content missing` rather than leaving the page. `_top` is what leaves it.
      # Takes everything `link_to` takes, and a `data:` of its own still wins.
      def turbo_link_to(name, path, **options)
        data = { turbo_frame: '_top' }.merge options.fetch(:data, {})

        link_to name, path, **options, data: data
      end

      # Where a form submits: the action that saves it, in the namespace the resource
      # was drawn in. `form_with model:` would ask polymorphic routing instead, which
      # knows the model and not the namespace, and names a route that does not exist.
      def resource_form_url(record)
        return url_for action: :create if record.new_record?

        url_for action: :update, id: record
      end

      # Path to this resource's new page, or nil when there is not one to link to.
      def new_resource_path
        return unless routed_action? 'new'

        url_for action: :new
      end

      # Label for a link to a resource: the icon its model picked, then its title,
      # with the letter at `key` marked where the link answers to one.
      def resource_label(resource, title, key = nil)
        name = key ? shortcut_title(title, key) : title
        icon = Recourse.known_icon resource

        safe_join [icon && tag.i(class: "bi bi-#{icon}"), name].compact, ' '
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

      # True when a sidebar entry names the page being shown, or the parent a nested
      # page sits under. The whole path, so a namespaced resource and its top-level
      # twin are not each other.
      def current_resource?(path)
        here = controller.controller_path

        path == here || here.start_with?("#{path}/")
      end

    private

      # Only a page beneath the index names itself, and names what it is showing.
      def breadcrumb_leaf
        case controller.action_name
        when 'new', 'create' then t 'recourse.new', model: resource_name
        when 'show', 'edit', 'update' then resource_record_label
        end
      end
    end
  end
end
