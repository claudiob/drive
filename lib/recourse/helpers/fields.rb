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
          ]
        end
      end

      # A field typed by what the column holds, not merely a text box.
      def resource_field(form, column, type: nil)
        association = belongs_to_association column
        return reference_field form, column, association if association

        # Rails mirrors `maxlength` into `size`, which would shrink the box to it.
        options = { class: 'form-control', size: nil }.merge field_html(column, type)

        return form.text_field column, **options, type: type if type
        # Only a password gets a password field, and it renders empty on purpose:
        # a stored password is written, never read back. An encrypted column is
        # not a password — it follows its own kind, value in the clear, since
        # editing one record is already a deliberate act. The mask stays on the
        # show page, where values are read rather than changed.
        return form.password_field column, **options if column == 'password'
        return form.email_field column, **options if column == 'email'

        kind_field form, column, **options
      end

      def encrypted_column?(column)
        resource_model.recourse_encrypted_names.include? column
      end
    end
  end
end
