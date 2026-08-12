module Recourse
  module Helpers
    # The menu a foreign key offers when its label is too long to be typed.
    module Comboboxes
      # A combobox of labels. The query fetches the two columns the menu shows and
      # nothing else, and the errors are its own work: `field_error_proc` only ever
      # sees the tags a form builder drew, and this is a partial.
      def combobox(form, column, association)
        label = association.klass.recourse_label

        render 'recourses/combobox', **combobox_locals(form, column),
                                     label: label.to_s,
                                     recourses: combobox_options(association.klass, label)
      end

      # What every combobox needs to know about the column it sets, whatever it offers
      # as choices: the enum one asks for these too, and gives `values:` instead.
      def combobox_locals(form, column)
        messages = errors_on column

        {
          name: form.field_name(column), id: form.field_id(column), invalid: messages.any?,
          feedback: messages.to_sentence.upcase_first.presence,
          placeholder: combobox_placeholder(column),
          required: required?(resource_model, column),
        }
      end

    private

      def combobox_options(klass, label)
        klass.select(:id, label).order label
      end

      def combobox_placeholder(column)
        placeholder(resource_model, column, nil) || t('recourse.select')
      end
    end
  end
end
