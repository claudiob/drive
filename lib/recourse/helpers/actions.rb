module Recourse
  module Helpers
    # The links at the end of a row: a look at a record, then a change to it.
    module Actions
      # Bootstrap Icons for the two pages a record has, so a row's links and a card's
      # tabs cannot drift apart. Written out rather than named as Unicon concepts:
      # these are the gem's own chrome, like the chevron and the search glass, and not
      # a model's picture of itself.
      ICONS = { show: 'eye', edit: 'pencil-square' }.freeze

      # The pages a record has, as `[label, path, current]` — a look first and a change
      # second, each only where its action is drawn, and nothing at all where neither
      # is. What the card at the top of a record's page draws its tabs from.
      def resource_tabs(record)
        paths = { show: show_resource_path(record), edit: edit_resource_path(record) }

        paths.filter_map do |action, path|
          [tab_label(action), path, current_tab?(action)] if path
        end
      end

      # Both of them, in that order, or nothing at all where a row offers neither.
      def resource_links(record)
        links = [show_resource_link(record), edit_resource_link(record)].compact
        return if links.empty?

        tag.div safe_join(links), class: 'd-flex gap-2'
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

      # Whether a row has anything to offer at the end of it. A table whose resource
      # has neither page ends at its last column rather than at a heading over
      # nothing.
      def resource_actions? = routed_action?('show') || routed_action?('edit')

    private

      def icon(action)
        tag.i class: "bi bi-#{ICONS[action]}"
      end

      def tab_label(action)
        safe_join [icon(action), t("recourse.#{action}")], ' '
      end

      # `update` redraws the form it rejected, so the edit tab is the current one on
      # that page too.
      def current_tab?(action)
        action == (controller.action_name == 'show' ? :show : :edit)
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
