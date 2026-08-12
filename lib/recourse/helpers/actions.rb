module Recourse
  module Helpers
    # The links at the end of a row: a look at a record, then a change to it.
    module Actions
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

        turbo_link_to tag.i(class: 'bi bi-eye'), path, aria: { label: t('recourse.show') }
      end

      # Pencil linking to a record's edit page, or nothing when there is not one.
      def edit_resource_link(record)
        path = edit_resource_path record
        return unless path

        turbo_link_to tag.i(class: 'bi bi-pencil-square'), path,
                      aria: { label: t('recourse.edit') }
      end

      # Whether a row has anything to offer at the end of it. A table whose resource
      # has neither page ends at its last column rather than at a heading over
      # nothing.
      def resource_actions? = routed_action?('show') || routed_action?('edit')

    private

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
