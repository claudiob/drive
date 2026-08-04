# Makes the database enforce what Phonable enforces in Rails: a stored phone is
# exactly ten digits. A separate migration because 20260804000001 has already run.
class AddPhoneCheckConstraintToContacts < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :contacts, "phone ~ '^[0-9]{10}$'", name: 'contacts_phone_ten_digits'
  end
end
