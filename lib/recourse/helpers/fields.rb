module Recourse
  module Helpers
    # Chooses the form field a column deserves, and the HTML that constrains it.
    module Fields
      # A field typed by what the column holds, not merely a text box.
      def resource_field(form, column)
        options = { class: 'form-control' }.merge field_html(column)

        return form.password_field column, **options if encrypted_column? column
        return form.email_field column, **options if column == 'email'
        return form.color_field column, **options if column == 'color'

        case column_type column
        when :date then form.date_field column, **options
        when :time then form.time_field column, **options
        else form.text_field column, **options
        end
      end

      # Browser-side constraints, taken from the column and its format validator.
      def field_html(column)
        pattern = column_pattern column
        html = { maxlength: column_limit(column), pattern: }.compact
        html[:inputmode] = :numeric if numeric? column, pattern

        html
      end

    private

      def encrypted_column?(column)
        Array(resource_model.encrypted_attributes).map(&:to_s).include? column
      end

      def column_type(column)
        resource_model.columns_hash[column]&.type
      end

      def column_limit(column)
        resource_model.columns_hash[column]&.limit
      end

      # An HTML pattern is anchored already, so \A and \z come off the Ruby one.
      def column_pattern(column)
        regexp = format_validator(column)&.options&.dig :with
        return unless regexp

        regexp.source.delete_prefix('\A').delete_suffix '\z'
      end

      def format_validator(column)
        resource_model.validators_on(column).find { |one| one.options[:with].is_a? Regexp }
      end

      def numeric?(column, pattern)
        digits_only?(pattern) || column_type(column) == :integer
      end

      # `\d` carries a letter, so it has to go before looking for real ones.
      def digits_only?(pattern)
        pattern.present? && !pattern.gsub('\d', '').match?(/[A-Za-z]/)
      end
    end
  end
end
