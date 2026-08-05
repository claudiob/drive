# Someone the host app can reach, identified by a unique 10-digit phone number.
class Contact < ApplicationRecord
  include Emailable, Phonable

  has_many :messages, dependent: :destroy

  encrypts :phone, deterministic: true
  encrypts :surname

  validates :phone, presence: true, uniqueness: true
end
