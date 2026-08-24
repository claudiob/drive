module Recourse
  module Helpers
    # Chooses the form field a column deserves, and labels it.
    module Fields
    private

      # One labelled field in the form's grid. `label:` overrides the heading and
      # `type:` overrides the input the column would otherwise have chosen.
      def field(name, **options)
        column = name.to_s
        label = options.fetch :label, reference_title(column, belongs_to_association(column))

        tag.div class: ROW do
          safe_join [
            @recourse_form.label(column, label, class: 'form-label'),
            resource_field(@recourse_form, column, type: options[:type]),
            field_comment(column),
          ].compact
        end
      end

      # What the database says the column is for, under the field that sets it — the
      # same `.form-text` an attachment's note sits in, being the same kind of answer
      # to a different kind of field. Nothing where the schema said nothing.
      def field_comment(column)
        comment = resource_model.recourse_comment column

        tag.div comment, class: 'form-text' if comment.present?
      end

      # A field typed by what the column holds, not merely a text box.
      def resource_field(form, column, type: nil)
        association = belongs_to_association column
        return reference_field form, column, association if association

        # Rails mirrors `maxlength` into `size`, which would shrink the box to it.
        options = { class: 'form-control', size: nil }.merge field_html(column, type)

        return form.text_field column, **options, type: type if type
        return form.email_field column, **options if column == 'email'

        kind_field form, column, **options
      end

      def encrypted_column?(column)
        resource_model.recourse_encrypted_names.include? column
      end
    end
  end
end
