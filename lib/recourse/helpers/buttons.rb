module Recourse
  module Helpers
    # The buttons a record's pages carry: an action the routes drew under it that has
    # no page of its own for a link to sit on.
    module Buttons
    private

      # A nested resource routed `create` with no `index` is reached from nowhere, so
      # its button lives on the record it hangs off — beside the breadcrumbs, on
      # whichever of that record's pages is open. The routes are the whole check, the
      # way they are for a bare create on an index: declaring one is the host saying
      # there is nothing to ask and nothing to list, only something to start.
      def bare_action_buttons(record)
        Recourse.nested_under(card_path).filter_map do |nested|
          next unless routed?(nested, 'create') && !routed?(nested, 'index')

          [bare_action_label(nested), bare_action_url(record, nested)]
        end
      end

      # The resource's own word, which a host renames in a locale like any other
      # model: `Add Jobber retrieval` rather than `Add booking exchange`.
      def bare_action_label(nested)
        t 'recourse.add', model: Recourse.downcase(Recourse.title(nested).singularize)
      end

      def bare_action_url(record, nested)
        parent = card_path.split('/').last.singularize

        url_for controller: "/#{nested}", action: :create, "#{parent}_id": record.id
      end
    end
  end
end
