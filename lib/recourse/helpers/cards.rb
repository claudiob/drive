module Recourse
  module Helpers
    # The tabs on the card a record's pages share: a look, a change, and each
    # nested index under the record, named by its count.
    module Cards
      # The pages of the record the card is about, as `[label, path, current]` — a
      # look first, a change second, then one tab per counted nested index, `8 ZIPs`
      # style. On a nested index the card is the parent record's, so the tabs are
      # too, and the count tab is the current one.
      def resource_tabs(record)
        path = card_path
        actions = %i[show edit].filter_map { |action| action_tab record, path, action }

        actions + counted_tabs(record, path)
      end

    private

      # The resource the card belongs to: the parent's, on a page nested under it.
      def card_path
        return controller.controller_path.rpartition('/').first if resource_parent

        controller.controller_path
      end

      def action_tab(record, path, action)
        return unless routed? path, action.to_s

        [
          tab_label(action), url_for(controller: "/#{path}", action:, id: record),
          current_action_tab?(action),
        ]
      end

      # `update` redraws the form it rejected, so the edit tab is current there too.
      # On a nested page neither is: the count tab is the page being read.
      def current_action_tab?(action)
        return false if resource_parent

        action == (controller.action_name == 'show' ? :show : :edit)
      end

      # One tab per counter cache whose rows have an index nested under the record,
      # named by the count read off the record itself: no query, like the column.
      def counted_tabs(record, path)
        record.class.recourse_counters.filter_map do |column, association|
          nested = "#{path}/#{association.name}"
          next unless routed? nested, 'index'

          [
            counted_tab_label(record.attributes[column], association),
            nested_index_path(record, path, nested), nested == controller.controller_path,
          ]
        end
      end

      # `8 ZIPs`, behind the counted model's icon — the one the sidebar and the
      # counter heading already draw — with the acronym surviving the downcase.
      def counted_tab_label(count, association)
        name = Recourse.downcase association.klass.model_name.human.pluralize(count)

        icon = tag.i class: "bi bi-#{Recourse.model_icon association.klass}"

        safe_join [icon, "#{count} #{name}"], ' '
      end

      def nested_index_path(record, path, nested)
        url_for controller: "/#{nested}", action: :index,
                "#{path.split('/').last.singularize}_id": record.id
      end

      def tab_label(action)
        safe_join [icon(action), t("recourse.#{action}")], ' '
      end
    end
  end
end
