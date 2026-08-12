module Recourse
  module Helpers
    # What one record reads as, laid out where its form's fields would be.
    module Values
      # One labelled value in the show page's grid: the heading a form would give the
      # column, and under it what the record says, formatted the way the table's cell
      # for the same column is. `label:` overrides the heading.
      def value(name, **options)
        column = name.to_s
        label = options.fetch :label, reference_title(column, belongs_to_association(column))

        tag.div class: 'mb-3 lg:col-6' do
          safe_join [tag.div(label, class: 'form-label'), value_control(column)]
        end
      end

      # What the record says for one column, or a dash where it says nothing. `false`
      # is something it says, so only nil and an empty list read as nothing.
      def resource_value(column)
        value = resource_cell resource_record, column

        value.to_s.empty? ? t('recourse.blank') : value
      end

    private

      def value_control(column)
        value = resource_value column
        return tag.div value, class: 'form-control-plaintext' unless encrypted_column? column

        masked_value value
      end

      # PII is a page's to show and nobody's to leak by accident, so it arrives as one
      # asterisk per character with the plaintext in an attribute the reveal reads: a
      # screenshot of the page discloses nothing, and reading one value takes a click.
      def masked_value(value)
        options = {
          class: 'form-control-plaintext d-flex gap-2',
          data: { controller: 'reveal', reveal_plain_value: value },
        }

        tag.div(**options) { safe_join [masked_span(value), reveal_button] }
      end

      def masked_span(value)
        tag.span '*' * value.length, data: { reveal_target: 'mask' }
      end

      def reveal_button
        tag.button t('recourse.reveal'), type: :button,
                                         class: 'btn btn-link btn-sm p-0 align-baseline',
                                         data: { action: 'reveal#show', reveal_target: 'button' }
      end
    end
  end
end
