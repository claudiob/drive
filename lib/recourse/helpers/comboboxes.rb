module Recourse
  module Helpers
    # The menu a foreign key offers when its label is too long to be typed.
    module Comboboxes
      # A combobox of labels. The query fetches the two columns the menu shows and
      # nothing else, and the errors are its own work: `field_error_proc` only ever
      # sees the tags a form builder drew, and this is a partial.
      def combobox(form, column, association)
        messages = errors_on column
        label = association.klass.recourse_label
        render 'recourses/combobox', name: form.field_name(column),
                                     id: form.field_id(column),
                                     invalid: messages.any?,
                                     feedback: messages.to_sentence.upcase_first.presence,
                                     label: label.to_s,
                                     placeholder: combobox_placeholder(column, association),
                                     required: required?(resource_model, column),
                                     recourses: combobox_options(association.klass, label)
      end

    private

      def combobox_options(klass, label)
        klass.select(:id, label).order label
      end

      def combobox_placeholder(column, association)
        placeholder(resource_model, column, nil) ||
          "Select a #{association.klass.model_name.human}…"
      end
    end
  end
end
