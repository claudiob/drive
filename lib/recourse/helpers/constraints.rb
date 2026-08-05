module Recourse
  module Helpers
    # Turns a model's validators into the HTML that constrains a form field.
    module Constraints
      # Shown for a field whose shape has one canonical example.
      SAMPLE_PLACEHOLDERS = { 'phone' => '555-555-5555', 'email' => 'michael@example.com' }.freeze

      # Browser-side constraints, every one of them read from the validators.
      def field_html(column, type = nil)
        pattern = column_pattern column
        html = { maxlength: column_maximum(column), minlength: column_minimum(column), pattern: }
        html[:inputmode] = :numeric if numeric? column, pattern
        html[:required] = true if required? column
        html[:placeholder] = placeholder column, type

        html.compact
      end

    private

      def column_maximum(column)
        length_options(column).values_at(:maximum, :is).compact.first
      end

      def column_minimum(column)
        length_options(column).values_at(:minimum, :is).compact.first
      end

      def length_options(column)
        validator(column, ActiveModel::Validations::LengthValidator)&.options || {}
      end

      # An HTML pattern is anchored already, so \A and \z come off the Ruby one.
      def column_pattern(column)
        regexp = validator(column, ActiveModel::Validations::FormatValidator)&.options&.dig :with
        return unless regexp

        regexp.source.delete_prefix('\A').delete_suffix '\z'
      end

      # An explicit type states what the field is, so it picks the sample; without
      # one a required field shows the shape it expects and an optional one says so.
      def placeholder(column, type)
        sample = SAMPLE_PLACEHOLDERS[(type || column).to_s]
        return sample if sample && (type || required?(column))

        'Optional' unless required? column
      end

      # A belongs_to validates its association, not the column, so both are asked.
      def required?(column)
        presence_validated?(column) || presence_validated?(column.delete_suffix('_id'))
      end

      def presence_validated?(attribute)
        validator(attribute, ActiveModel::Validations::PresenceValidator).present?
      end

      def numeric?(column, pattern)
        digits_only?(pattern) ||
          validator(column, ActiveModel::Validations::NumericalityValidator).present?
      end

      # `\d` carries a letter, so it has to go before looking for real ones.
      def digits_only?(pattern)
        pattern.present? && !pattern.gsub('\d', '').match?(/[A-Za-z]/)
      end

      def validator(attribute, kind)
        resource_model.validators_on(attribute).find { |one| one.is_a? kind }
      end
    end
  end
end
