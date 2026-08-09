# An integration the host app has connected: where a booking can be routed
# through, and where a contact can have arrived from.
class App < ApplicationRecord
  include Recoursive

  belongs_to :agent, optional: true
  has_many :bookings, dependent: :nullify
  has_many :contacts, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
