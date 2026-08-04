# Creates the contacts table: a phone is required and unique, the rest optional.
class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :phone, null: false, index: { unique: true }
      t.string :email
      t.string :name
      t.string :surname

      t.timestamps
    end
  end
end
