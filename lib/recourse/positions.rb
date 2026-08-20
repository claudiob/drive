# Reopened for the order a reader sets by hand, which the routes, the table and the
# controller each have to ask a model about.
module Recourse
  # What a model says about being arranged rather than sorted. Extended onto
  # `Recourse`, so every one of these is `Recourse.something` wherever it is called
  # from.
  module Positions
    # The word a host writes where `:asc` or `:desc` would go, saying that this column
    # is nobody's to sort by and everybody's to arrange. `recourse_order` carries it
    # because the order a table is read in and the order somebody put it in are one
    # fact: a model that names a second one would be describing two different tables.
    POSITIONABLE = :positionable

    # The column a table is arranged by, or nil where a model named none. A string,
    # like every other column name the gem passes around.
    def position_column(model)
      column = positionable_key model.recourse_order
      refuse_unarrangeable model, column if column

      column
    end

    # `recourse_order` as `order` will take it: the word above means ascending to
    # everybody downstream, and Active Record rejects a direction it has never heard
    # of. Read here and nowhere else, so the hash a host wrote stays the hash it wrote.
    def order_for(model)
      order = model.recourse_order
      return order unless order.is_a? Hash

      order.transform_values { |direction| arranged?(direction) ? :asc : direction }
    end

  private

    def arranged?(direction)
      direction.to_sym == POSITIONABLE
    end

    # The one key a host marked, or nil. Two would be two orders claiming the same
    # rows, which no table can be in at once, so it is refused where it is written
    # rather than left to whichever key `order` happened to apply last.
    def positionable_key(order)
      return unless order.is_a? Hash

      keys = order.select { |_, direction| arranged? direction }.keys
      raise Error, I18n.t('recourse.two_positions', keys: keys.map(&:inspect).to_sentence) if
        keys.many?

      keys.first&.to_s
    end

    # A column no table can be ordered by is a model to fix rather than a page that
    # quietly ignores what it was told. Both questions are answered out of the schema
    # cache, so asking costs nothing after the first look.
    def refuse_unarrangeable(model, column)
      if model.column_names.exclude? column
        raise Error, I18n.t('recourse.missing_position', model:, column:)
      elsif model.ransortable_attributes.exclude? column
        raise Error, I18n.t('recourse.unsorted_position', model:, column:)
      end
    end
  end

  extend Positions
end
