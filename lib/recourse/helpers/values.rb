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
          safe_join [
            tag.div(label, class: 'form-label'),
            tag.div(resource_value(column), class: 'form-control-plaintext'),
          ]
        end
      end

      # What the record says for one column, or a dash where it says nothing. `false`
      # is something it says, so only nil and an empty list read as nothing.
      def resource_value(column)
        value = resource_cell resource_record, column

        value.to_s.empty? ? t('recourse.blank') : value
      end
    end
  end
end
