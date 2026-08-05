# One of the United States ZIP codes, in the county it mostly belongs to.
class ZIP < ApplicationRecord
  include Recoursive

  belongs_to :county
  belongs_to :market, optional: true

  validates :code, presence: true, uniqueness: true, format: { with: /\A\d{5}\z/ }
  validates :city, presence: true
  validates :time_zone, presence: true
end
