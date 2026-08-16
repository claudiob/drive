module Recourse
  module Helpers
    # What a nested index's tab on the parent's card reads as.
    module Tabs
    private

      # The icon is the counted model's own, whatever leads the words beside it.
      def association_tab_label(record, association, namespace)
        icon = Recourse.known_model_icon association.klass

        words = [icon && tag.i(class: "bi bi-#{icon}"), tab_name(record, association, namespace)]

        safe_join words.compact, ' '
      end

      # `8 ZIPs` where the record keeps a count — read off the record itself, no
      # query, like the column — and the bare `ZIPs` where it keeps none. A namespace
      # the routes drew leads either of those, so two nestings of one model read
      # apart: `10 visited places` beside `4 booked places`, `Visited places` beside
      # `Booked places`. Whatever leads earns the downcase, and a title that leads
      # keeps its capital — which is what puts these beside Show and Edit.
      def tab_name(record, association, namespace)
        count = tab_count record, association
        lead = [count, namespace_words(namespace)].compact_blank.join ' '
        title = Recourse.model_title association.klass, count: count, lower: lead.present?

        [lead.presence&.upcase_first, title].compact.join ' '
      end

      def tab_count(record, association)
        column = counter_column_of record.class, association

        record.attributes[column] if column
      end

      # `on_hold` reads as `on hold`, and an acronym among them keeps its capitals.
      def namespace_words(namespace)
        namespace.map { |segment| Recourse.downcase segment.humanize }.join ' '
      end

      def counter_column_of(model, association)
        model.recourse_counters.find { |_, one| one == association }&.first
      end
    end
  end
end
