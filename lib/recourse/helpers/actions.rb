module Recourse
  module Helpers
    # The action columns a row opens with: a look at a record, then a change to it.
    module Actions
      # The two pages a record has, named as the concepts an icon set knows rather
      # than as one set's own word for them, so what draws them is Unicon's business
      # here as everywhere else. A row's links and a card's tabs read the same map,
      # so the two cannot drift apart.
      ICONS = { show: :view, edit: :edit }.freeze

      # An action column's heading: the icon on the header row — the column is as
      # narrow as the icon in it, with no room for a word — and the action's own
      # word in every other, which is what each `data-cell` labels itself with.
      def action_header(action)
        label = t "recourse.#{action}"
        return label unless @recourse_headers

        icon_tag ICONS[action], label: label, role: :img, data: tooltip_on_top(label)
      end

      # Whether a record's own page is there to be linked to, wherever its routes
      # were drawn: a nested table's rows lead to the resource's own pages, the ones
      # a nested route leaves to it, so the columns are the same either way.
      def resource_action?(action)
        controller.class.action_methods.include?(action) &&
          routed?(resource_controller_path, action)
      end

      # Eye linking to a record's show page, or nothing when there is not one.
      def show_resource_link(record)
        path = show_resource_path record
        return unless path

        turbo_link_to icon_tag(ICONS[:show]), path, aria: { label: t('recourse.show') }
      end

      # Pencil linking to a record's edit page, or nothing when there is not one.
      def edit_resource_link(record)
        path = edit_resource_path record
        return unless path

        turbo_link_to icon_tag(ICONS[:edit]), path, aria: { label: t('recourse.edit') }
      end

    private

      def tooltip_on_top(title)
        # `bs_title` is what Bootstrap's tooltip reads, and the controller is what
        # makes one: Bootstrap never wires a tooltip on its own.
        { controller: 'tooltip', bs_placement: 'top', bs_title: title }
      end

      def show_resource_path(record)
        resource_action_path 'show', record
      end

      def edit_resource_path(record)
        resource_action_path 'edit', record
      end

      # Named by controller rather than by action alone: on a nested page the two
      # differ, and a bare `action:` would look for the member route the nesting
      # does not draw.
      def resource_action_path(action, record)
        return unless resource_action? action

        url_for controller: "/#{resource_controller_path}", action: action, id: record
      end
    end
  end
end
