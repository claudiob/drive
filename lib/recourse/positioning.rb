module Recourse
  # Moves one row of an arranged table to a place in it, and closes the gap it leaves
  # by shifting whatever it displaced one step the other way.
  class Positioning
    # The rows a position is counted within, the row being moved, and the column it is
    # counted in. A relation rather than a model, because which rows those are is the
    # route's answer rather than the model's, and the controller has already asked it.
    def initialize(relation, record, column)
      @relation = relation
      @record = record
      @column = column
    end

    # Puts the record at `position`, counting from one and never past the end — a drag
    # reports where a row was dropped, and a page is not the whole table.
    def move_to(position)
      target = position.to_i.clamp 1, @relation.count
      current = @record[@column]
      return if target == current

      @relation.transaction do
        displace current, target
        @record.update! @column => target
      end
    end

  private

    # Everything between where the row was and where it is going moves one step
    # towards the space it left: moving up, the block beneath it shifts down; moving
    # down, the block above it shifts up. That is what the two ranges say, the
    # half-open one compensating for the row itself being left out of the count.
    def displace(current, target)
      delta = current <=> target
      between = delta.positive? ? target...current : current..target

      @relation.excluding(@record).where(@column => between).update_all shift(delta)
    end

    # One statement however many rows it moves, and it touches them in the same
    # breath: `update_all` runs no callbacks, so nothing else would tell the relation
    # a table caches on that its version has changed, and the old order would be
    # served straight back.
    def shift(delta)
      column = @relation.klass.connection.quote_column_name @column
      moved = "#{column} = #{column} + ?"

      return [moved, delta] unless @relation.klass.column_names.include? 'updated_at'

      ["#{moved}, updated_at = ?", delta, Time.current]
    end
  end
end
