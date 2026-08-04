# Makes the database enforce the ten digits that Phonable enforces in Rails.
class AddPhoneCheckConstraintToContacts < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :contacts, "phone ~ '^[0-9]{10}$'", name: 'contacts_phone_ten_digits'
  end
end
