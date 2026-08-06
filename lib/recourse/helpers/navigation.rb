module Recourse
  module Helpers
    # Helpers for the navbar and the sidebar.
    module Navigation
      # Trail to the current page as [name, title, path]; a nil path is this page. The
      # name is the resource's, which is what an icon is looked up by.
      def resource_breadcrumbs
        name = controller.controller_name
        leaf = breadcrumb_leaf
        return [[name, resources_name, nil]] unless leaf

        [[name, resources_name, url_for(action: :index)], [name, leaf, nil]]
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

      # Label for a link to a resource: its icon, then its title. The model says which
      # icon; nothing here holds a list of them.
      def resource_label(name, title)
        icon = Recourse.icon name, :bootstrap

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
