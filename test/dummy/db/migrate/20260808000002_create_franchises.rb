# Creates the franchises table. The key is encrypted and non-deterministic, so
# it carries no shape constraint and no unique index — ciphertext differs on
# every write, so a duplicate would never be found even if one existed.
class CreateFranchises < ActiveRecord::Migration[8.1]
  def change
    create_table :franchises do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :key
      t.string :lead_status
      t.string :lead_source, default: 'HouseAccount'
      t.boolean :multiple, default: true, null: false
      t.integer :providers_count, default: 0, null: false

      t.timestamps
    end
  end
end
