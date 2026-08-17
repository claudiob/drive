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

      # Buttons no route can name: an action a record only sometimes offers, or one
      # whose wording counts something. A host answers `recourse_extra_actions` in a
      # helper of its own with `[label, path, method]` triples — the same three a
      # bare action comes to, so it earns the same button — and returns none where
      # the record is not one this action is for.
      def host_actions(record)
        return [] unless respond_to? :recourse_extra_actions

        recourse_extra_actions record
      end

      # The first of the two the routes drew that needs no id: a `create` on the
      # collection, or a singular resource's `destroy`. A member action wants the row
      # it acts on, and a row is what a table is for.
      def bare_action_button(record, nested)
        action, method = BARE_ACTIONS.find { |one, _| idless_route? nested, one }
        return unless action

        [bare_action_label(nested, action), bare_action_url(record, nested, action), method]
      end

      # The resource's own word, which a host renames in a locale like any other
      # model: `Add Jobber retrieval` rather than `Add booking exchange`.
      def bare_action_label(nested, action)
        model = Recourse.downcase Recourse.known_title(nested).singularize

        t "recourse.#{action == :create ? 'add' : 'delete'}", model:
      end

      def bare_action_url(record, nested, action)
        parent = card_path.split('/').last.singularize

        url_for controller: "/#{nested}", action:, "#{parent}_id": record.id
      end
    end
  end
end
