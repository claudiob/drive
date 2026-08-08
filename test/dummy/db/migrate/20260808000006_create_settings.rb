# Creates the settings table: a key-value pair the host app looks up by key,
# typed by its kind. fountain also carries a `type` column here, left out on
# purpose — Rails would read it as single-table inheritance, not as this kind.
class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_enum :setting_kind, Setting::KINDS

    create_table :settings do |t|
      t.string :key, null: false, index: { unique: true }
      t.enum :kind, enum_type: :setting_kind, default: :number, null: false
      t.string :value, null: false
      t.references :agent, foreign_key: true

      t.timestamps
    end
  end
end
