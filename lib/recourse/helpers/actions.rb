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

      def show_resource_path(record)
        return unless routed_action? 'show'

        url_for action: :show, id: record
      end

      def edit_resource_path(record)
        return unless routed_action? 'edit'

        url_for action: :edit, id: record
      end
    end
  end
end
