module Recourse
  module Helpers
    # The menus a form offers: one of the records a foreign key can point at, and one
    # of the concepts an icon can be picked from.
    module Comboboxes
      # A combobox of labels. The query fetches the two columns the menu shows and
      # nothing else, and the errors are its own work: `field_error_proc` only ever
      # sees the tags a form builder drew, and this is a partial.
      def combobox(form, column, association)
        label = association.klass.recourse_label

        render 'recourses/combobox', **combobox_locals(form, column),
                                     label: label.to_s,
                                     placeholder: combobox_placeholder(column, association),
                                     recourses: combobox_options(association.klass, label),
                                     fallback: combobox_fallback(association.klass)
      end

      # A combobox of every concept an icon can be picked from, each row drawn with the
      # icon it names. The list is the same for every form, so it is cached under a
      # fixed key rather than a digest of anything.
      def icon_combobox(form, column)
        render 'recourses/combobox', **combobox_locals(form, column),
                                     label: column,
                                     placeholder: 'Select an icon…',
                                     concepts: icon_concepts
      end

      # What a combobox row is drawn with: the concept the record picked, or what its
      # model is drawn with where it picked none. The column holds a concept rather than
      # one system's name, which is what lets the same choice serve every client.
      def combobox_icon(recourse, fallback)
        concept = recourse.attributes['icon'].presence
        icon = concept ? Unicon[concept][:bootstrap] : fallback
        return unless icon

        safe_join [tag.i(class: "bi bi-#{icon}"), ' ']
      end

    private

      # What every combobox needs, whatever it goes on to list.
      def combobox_locals(form, column)
        messages = errors_on column

        {
          name: form.field_name(column), id: form.field_id(column),
          invalid: messages.any?,
          feedback: messages.to_sentence.upcase_first.presence,
          required: required?(resource_model, column),
        }
      end

      # `meanings`, not `concepts`: the latter counts every synonym a model name might
      # arrive under, and offering both `house` and `home` drawing the same glyph is
      # noise to choose from. Actions are absent from it too — nothing has a Close.
      def icon_concepts
        Unicon.meanings.map { |concept| [concept, Unicon[concept][:bootstrap]] }
      end

      # Only the columns the menu shows, plus the icon where the model keeps one.
      def combobox_options(klass, label)
        columns = [:id, label]
        columns << :icon if klass.column_names.include? 'icon'

        klass.select(*columns).order label
      end

      # Nothing to fall back to unless the model's records can carry an icon at all.
      def combobox_fallback(klass)
        Recourse.resolve klass.recourse_icon, :bootstrap if klass.column_names.include? 'icon'
      end

      def combobox_placeholder(column, association)
        placeholder(resource_model, column, nil) ||
          "Select a #{association.klass.model_name.human}…"
      end
    end
  end
end
