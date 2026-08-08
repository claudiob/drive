# What a provider does, and what a booking asks for.
class Specialty < ApplicationRecord
  has_many :bookings, dependent: :nullify

  validates :name, presence: true
end
