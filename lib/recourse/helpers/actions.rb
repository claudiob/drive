module Recourse
  module Helpers
    # The action columns a row opens with: a look at a record, then a change to it.
    module Actions
      # Bootstrap Icons for the two pages a record has, so a row's links and a card's
      # tabs cannot drift apart. Written out rather than named as Unicon concepts:
      # these are the gem's own chrome, like the chevron and the search glass, and not
      # a model's picture of itself.
      ICONS = { show: 'eye', edit: 'pencil-square' }.freeze

      # An action column's heading: the icon on the header row — the column is as
      # narrow as the icon in it, with no room for a word — and the action's own
      # word in every other, which is what each `data-cell` labels itself with.
      def action_header(action)
        label = t "recourse.#{action}"
        return label unless @recourse_headers

        tag.i class: "bi bi-#{ICONS[action]}", role: :img, aria: { label: label },
              data: tooltip_on_top(label)
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

        turbo_link_to icon(:show), path, aria: { label: t('recourse.show') }
      end

      # Pencil linking to a record's edit page, or nothing when there is not one.
      def edit_resource_link(record)
        path = edit_resource_path record
        return unless path

        turbo_link_to icon(:edit), path, aria: { label: t('recourse.edit') }
      end

    private

      def icon(action)
        tag.i class: "bi bi-#{ICONS[action]}"
      end

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
