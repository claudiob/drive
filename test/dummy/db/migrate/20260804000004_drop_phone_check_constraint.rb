# An encrypted phone is stored as ciphertext, which is not ten digits.
class DropPhoneCheckConstraint < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :contacts, "phone ~ '^[0-9]{10}$'",
                            name: 'contacts_phone_ten_digits'
  end
end
