# Someone the host app can reach, identified by a unique 10-digit phone number.
class Contact < ApplicationRecord
  validates :phone, presence: true, uniqueness: true, format: { with: /\A\d{10}\z/ }
end
