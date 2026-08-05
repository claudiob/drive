module Recourse
  module Helpers
    # Helpers for the navbar and the sidebar.
    module Navigation
      # Trail to the current page as [title, path] pairs; a nil path is this page.
      # A controller with no index has nowhere to link back to, so it names itself
      # and stops — a sign-in page, say, which is not a resource at all.
      def resource_breadcrumbs
        return [[breadcrumb_title, nil]] unless routed? controller.controller_path, 'index'

        leaf = breadcrumb_leaf
        return [[resources_name, nil]] unless leaf

        [[resources_name, url_for(action: :index)], [leaf, nil]]
      end

      # Pencil linking to a record's edit page, or nothing when there is not one.
      def edit_resource_link(record)
        path = edit_resource_path record
        return unless path

        link_to tag.i(class: 'bi bi-pencil-square'), path, aria: { label: 'Edit' }
      end

      # Path to this resource's new page, or nil when there is not one to link to.
      def new_resource_path
        return unless controller.class.action_methods.include? 'new'
        return unless routed? controller.controller_path, 'new'

        url_for action: :new
      end

      # Path that ends an agent's session, or nil where the app draws no such route.
      # That route's name is the one installed alongside Google sign-in, so this is a
      # convention rather than a guess, and its absence just hides the link.
      def recourse_logout_path
        return unless routed? 'agents/sessions', 'destroy'

        url_for controller: '/agents/sessions', action: :destroy
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

      # What a page with no index calls itself: the title it set, since there is no
      # resource to name after. Falls back to the controller, which always answers.
      def breadcrumb_title
        content_for(:title).presence || resources_name
      end

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
