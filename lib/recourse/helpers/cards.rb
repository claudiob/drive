module Recourse
  module Helpers
    # The tabs on the card a record's pages share: a look, a change, and each
    # nested index under the record — counted where the record keeps a count.
    module Cards
      # The pages of the record the card is about, as `[label, path, current]` — a
      # look first, a change second, then one tab per nested index: `8 ZIPs` where
      # a counter cache answers, the bare `Settings` where none does. On a nested
      # index the card is the parent record's, so the tabs are too, and the nested
      # tab is the current one.
      def resource_tabs(record)
        path = card_path
        actions = %i[show edit].filter_map { |action| action_tab record, path, action }

        actions + nested_tabs(record, path)
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

      # One tab per has_many whose rows have an index nested under the record. The
      # nested route is the whole requirement: a counter cache only decides how the
      # tab reads, never whether it is there.
      def nested_tabs(record, path)
        record.class.reflect_on_all_associations(:has_many).filter_map do |association|
          nested = "#{path}/#{association.name}"
          next unless routed? nested, 'index'

          [
            association_tab_label(record, association),
            nested_index_path(record, path, nested), nested == controller.controller_path,
          ]
        end
      end

      # `8 ZIPs` where the record keeps a count — read off the record itself, no
      # query, like the column — and the bare `ZIPs` where it keeps none. The count
      # is what earns the downcase: a word that leads keeps its capital, like the
      # Show and Edit beside it. The icon is the counted model's own either way.
      def association_tab_label(record, association)
        icon = Recourse.known_model_icon association.klass
        column = counter_column_of record.class, association
        label = if column
                  counted_tab_name record.attributes[column], association
                else
                  association.klass.model_name.human.pluralize
                end

        safe_join [icon && tag.i(class: "bi bi-#{icon}"), label].compact, ' '
      end

      def counter_column_of(model, association)
        model.recourse_counters.find { |_, one| one == association }&.first
      end

      def counted_tab_name(count, association)
        "#{count} #{Recourse.downcase association.klass.model_name.human.pluralize(count)}"
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
