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

      # What the database says the column is for, under the field that sets it.
      def field_comment(column)
        field_note resource_model.recourse_comment(column)
      end

      # The line under a field saying what somebody wants to know before filling it in:
      # what the column is for, or what the record already has attached. Both come
      # through here, so the two read as one kind of thing and how they read is settled
      # in one place. Nothing at all where there is nothing to say.
      #
      # `mt-1` because Bootstrap's `.form-text` declares `--bs-form-text-margin-top` and
      # never applies it; `.25rem` is what that variable holds, so this is the gap the
      # class already meant. `fg-secondary` for a line that answers a question nobody
      # asked — quieter than the value it sits under, and quieter than `.form-text`'s
      # own `--bs-fg-2`, which a utility later in the cascade is what overrides.
      def field_note(text)
        tag.div text, class: 'form-text mt-1 fg-secondary' if text.present?
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
