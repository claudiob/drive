class CreateMsas < ActiveRecord::Migration[8.1]
  def change
    create_table :msas do |t|
      # Five characters exactly, which the model states as a length — and a length is
      # what tells a form to ask for a code rather than list every row.
      t.string :code, limit: 5, null: false
      # Written once by this migration and never again: what `readonly_attributes`
      # keeps off a form, and off the table it would otherwise head.
      t.string :fips, limit: 5, null: false
      t.string :name, null: false
      t.integer :places_count, null: false, default: 0

      t.timestamps
    end

    add_index :msas, :code, unique: true
    add_index :msas, :fips, unique: true
    # Not unique: two metropolitan areas share a name often enough that the index is
    # about sorting and searching rather than about identity.
    add_index :msas, :name

    # One row over MENU_LIMIT, which is the whole point of this table: a foreign key
    # pointing here is typed rather than picked from a menu of every row.
    up_only { connection.execute msa_rows }
  end

private

  def msa_rows
    values = (1..101).map do |number|
      code = format 'M%04d', number
      fips = format '%05d', number * 7
      "('#{code}', '#{fips}', 'Metro #{format '%03d', number}', 0, #{now}, #{now})"
    end

    <<~SQL.squish
      insert into msas (code, fips, name, places_count, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end

  def now = 'current_timestamp'
end
