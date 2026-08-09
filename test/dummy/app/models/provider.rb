# Someone who does jobs for the host app, identified by a unique phone number.
class Provider < ApplicationRecord
  include Phonable

  # Team sizes a provider identifies with, smallest to largest. A provider with...
  TEAM_SIZES = [
    :solo, # ... just themselves and no employees
    :small, # ... a handful of employees
    :medium, # ... an established local team
    :large, # ... multiple crews or more than one location
    :enterprise, # ... a large regional or national operation
  ]

  belongs_to :franchise, optional: true, counter_cache: true
  has_many :bookings, dependent: :nullify

  enum :team_size, TEAM_SIZES.index_by(&:itself)

  encrypts :phone, deterministic: true
  encrypts :pin

  validates :name, :email, presence: true
  validates :phone, presence: true, uniqueness: true
  # Six digits, which is a shape the browser can check and a title can name — the
  # only pattern in this app without a canonical sample to show instead.
  validates :pin, length: { is: 6 }, format: { with: /\A\d{6}\z/ }, allow_nil: true
  validates :commission_rate, :time_zone, presence: true
  validates :commission_type, presence: true, length: { is: 1 }

  with_options inclusion: { in: [true, false], message: 'must be true or false' } do
    validates :active, :insured, :subscribed
  end
end
