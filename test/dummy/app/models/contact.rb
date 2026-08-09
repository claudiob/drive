# Someone the host app can reach, identified by a unique 10-digit phone number.
class Contact < ApplicationRecord
  include Emailable, Phonable, Recoursive

  belongs_to :app, optional: true
  belongs_to :source, optional: true, counter_cache: true
  belongs_to :agent, optional: true, counter_cache: true
  has_many :bookings, dependent: :destroy
  has_many :messages, dependent: :destroy

  encrypts :phone, deterministic: true
  encrypts :surname

  validates :phone, presence: true, uniqueness: true
end
