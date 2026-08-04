# Someone the host app can reach, identified by a unique 10-digit phone number.
class Contact < ApplicationRecord
  include Phonable

  validates :phone, presence: true, uniqueness: true
end
