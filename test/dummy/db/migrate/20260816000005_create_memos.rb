class CreateMemos < ActiveRecord::Migration[8.1]
  # Six a person, and no counter cache, so the tab beside Places reads as the bare
  # word where that one carries a figure.
  PER_PERSON = 6

  def change
    create_table :memos do |t|
      # Optional, and nullified rather than destroyed when the person goes: a memo
      # outlives whoever it was about.
      t.references :person, foreign_key: { on_delete: :nullify }
      # Polymorphic, so it names no one table: nothing can label it, list it,
      # filter by it or search through it, and its column is a number like any
      # other. Optional, and never filled — what it proves is that the gem asks
      # what a key points at before reaching for it.
      t.references :about, polymorphic: true
      t.text :body, null: false

      t.timestamps
    end

    up_only { connection.execute memo_rows }
  end

private

  def memo_rows
    values = (1..Person.count).flat_map do |person|
      (1..PER_PERSON).map do |number|
        "(#{person}, 'Memo #{number} about person #{person}.', " \
          'current_timestamp, current_timestamp)'
      end
    end

    <<~SQL.squish
      insert into memos (person_id, body, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
