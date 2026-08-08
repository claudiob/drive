module Recourse
  module Helpers
    # Fields for a foreign key: a value to type, or a list to pick from.
    module References
      # The belongs_to a column is the foreign key of, or nil when it is not one.
      def belongs_to_association(column)
        resource_model.reflect_on_all_associations(:belongs_to)
                      .find { |one| one.foreign_key.to_s == column }
      end

      # A field for a foreign key. Where the label has a length it is short enough
      # to type, and typing it beats listing every record there is to pick from.
      def reference_field(form, column, association)
        return typed_reference form, column, association if typed_reference? association

        combobox form, column, association
      end

      # What the record a foreign key points at is called, rather than the id that
      # points at it. `association` reads the target without naming a method for it.
      def reference_cell(resource, association)
        record = resource.association(association.name).reader
        return unless record

        record.attributes[association.klass.recourse_label.to_s]
      end

      # Heading for a column, naming the attribute too where one has to be typed:
      # `ZIP code` rather than `ZIP`, since a code is what the field asks for.
      def reference_title(column, association)
        return resource_column_title column unless typed_reference? association

        association.klass.recourse_reference_name
      end

    private

      def typed_reference?(association)
        association&.klass&.recourse_typed_reference?
      end

      def typed_reference(form, column, association)
        messages = errors_on column
        id = form.field_id column
        # `params` rather than the record: a code that matched nothing was never
        # assigned, so only the request still knows what was typed.
        html = typed_html(column, association).merge(
          class: messages.any? ? 'form-control is-invalid' : 'form-control',
          value: params.dig(resource_key, column),
          'aria-describedby': ("#{id}_error" if messages.any?)
        )

        safe_join [form.text_field(column, **html), invalid_feedback(messages, id)]
      end

      # The shape belongs to the attribute typed; whether it is required does not,
      # since that is the association's rule and not the other model's.
      def typed_html(column, association)
        klass = association.klass
        shape = field_html klass.recourse_label.to_s, nil, klass
        own = {
          required: (true if required? resource_model, column), size: nil,
          placeholder: placeholder(resource_model, column, nil),
        }

        shape.except(:required, :placeholder).merge own
      end

      # Bootstrap only reveals this next to an `.is-invalid` sibling of its own.
      def invalid_feedback(messages, id)
        return if messages.empty?

        tag.small messages.to_sentence.upcase_first, class: 'invalid-feedback', id: "#{id}_error"
      end

      # A belongs_to reports on the association, so `state_id` asks about `state`.
      def errors_on(column)
        attribute = column.delete_suffix '_id'
        messages = resource_record.errors[column]
        return messages if attribute == column

        messages + resource_record.errors[attribute]
      end
    end
  end
end
