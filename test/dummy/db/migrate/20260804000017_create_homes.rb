# Creates the homes table, joining a contact to a location in a role.
class CreateHomes < ActiveRecord::Migration[8.1]
  def change
    create_enum :home_role, Home::ROLES

    create_table :homes do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.enum :role, enum_type: :home_role, default: :homeowner, null: false

      t.timestamps
    end

    add_index :homes, %i[contact_id location_id], unique: true
  end
end
