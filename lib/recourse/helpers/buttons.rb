module Recourse
  module Helpers
    # The buttons a record's pages carry: an action the routes drew under it that has
    # no page of its own for a link to sit on.
    module Buttons
      # What a bare action may be, and the verb each one is asked with. `create`
      # starts something and `destroy` undoes it; anything else wants a page.
      BARE_ACTIONS = { create: :post, destroy: :delete }.freeze

    private

      # A nested resource routed without an `index` is reached from nowhere, so its
      # button lives on the record it hangs off — beside the breadcrumbs, on
      # whichever of that record's pages is open. The routes are the whole check, the
      # way they are for a bare create on an index: declaring one is the host saying
      # there is nothing to ask and nothing to list, only something to do.
      def bare_action_buttons(record)
        Recourse.nested_under(card_path).filter_map do |nested|
          next if routed? nested, 'index'

          bare_action_button record, nested
        end
      end

      # The first of the two the routes drew, since a resource offering both is
      # asking for a page rather than a button.
      def bare_action_button(record, nested)
        action, method = BARE_ACTIONS.find { |one, _| routed? nested, one.to_s }
        return unless action

        [bare_action_label(nested, action), bare_action_url(record, nested, action), method]
      end

      # The resource's own word, which a host renames in a locale like any other
      # model: `Add Jobber retrieval` rather than `Add booking exchange`.
      def bare_action_label(nested, action)
        model = Recourse.downcase Recourse.title(nested).singularize

        t "recourse.#{action == :create ? 'add' : 'delete'}", model:
      end

      def bare_action_url(record, nested, action)
        parent = card_path.split('/').last.singularize

        url_for controller: "/#{nested}", action:, "#{parent}_id": record.id
      end
    end
  end
end
