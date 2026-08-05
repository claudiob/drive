module Recourse
  module Helpers
    # Chooses the form field a column deserves, labels it and reports its errors.
    module Fields
      # One labelled field in the form's grid. `label:` overrides the heading and
      # `type:` overrides the input the column would otherwise have chosen.
      def field(name, **options)
        column = name.to_s
        label = options.fetch :label, resource_column_title(column)

        tag.div class: 'mb-3 lg:col-6' do
          safe_join [@recourse_form.label(column, label, class: 'form-label'),
                     resource_field(@recourse_form, column, type: options[:type]),
                     invalid_feedback(column)].compact
        end
      end

      # A field typed by what the column holds, not merely a text box.
      def resource_field(form, column, type: nil)
        association = belongs_to_association column
        return combobox form, column, association if association

        # Rails mirrors `maxlength` into `size`, which would shrink the box to it.
        options = { class: control_class(column), size: nil }.merge field_html(column, type)

        return form.text_field column, **options, type: type if type
        return form.password_field column, **options if encrypted_column? column
        return form.email_field column, **options if column == 'email'
        return form.color_field column, **options if column == 'color'

        dated_field form, column, **options
      end

    private

      def dated_field(form, column, **)
        case attribute_type column
        when :date then form.date_field column, **
        when :time then form.time_field column, **
        when :datetime then form.datetime_local_field column, **
        else form.text_field column, **
        end
      end

      # A foreign key is chosen from a list, so it gets a combobox of names. The
      # query fetches the two columns the menu shows and nothing else.
      def combobox(form, column, association)
        render 'recourses/combobox', name: form.field_name(column),
                                     id: form.field_id(column),
                                     control: control_class(column),
                                     placeholder: combobox_placeholder(column, association),
                                     required: required?(column),
                                     recourses: association.klass.select(:id, :name).order(:name)
      end

      def belongs_to_association(column)
        resource_model.reflect_on_all_associations(:belongs_to)
                      .find { |one| one.foreign_key.to_s == column }
      end

      def combobox_placeholder(column, association)
        placeholder(column, nil) || "Select a #{association.klass.model_name.human}…"
      end

      def control_class(column)
        errors_on(column).any? ? 'form-control is-invalid' : 'form-control'
      end

      # Bootstrap only reveals this when it follows an `.is-invalid` sibling.
      def invalid_feedback(column)
        messages = errors_on column
        return if messages.empty?

        tag.div messages.to_sentence.upcase_first, class: 'invalid-feedback'
      end

      # A belongs_to reports on the association, so `state_id` asks about `state`.
      def errors_on(column)
        attribute = column.delete_suffix '_id'
        messages = resource_record.errors[column]
        return messages if attribute == column

        messages + resource_record.errors[attribute]
      end

      def encrypted_column?(column)
        Array(resource_model.encrypted_attributes).map(&:to_s).include? column
      end

      # The model's own attribute type, so an `attribute` override still counts.
      def attribute_type(column)
        resource_model.type_for_attribute(column).type
      end
    end
  end
end
