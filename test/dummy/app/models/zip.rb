# One of the United States ZIP codes, in the county it mostly belongs to.
class ZIP < ApplicationRecord
  include Recoursive

  belongs_to :county, counter_cache: true, touch: true
  belongs_to :market, optional: true, counter_cache: true, touch: true
  has_many :bookings, dependent: :destroy
  has_many :locations, dependent: :destroy

  validates :code, uniqueness: true, length: { is: 5 }, format: { with: /\A\d{5}\z/ }
  validates :code, :city, presence: true
  validates :time_zone, presence: true
end
