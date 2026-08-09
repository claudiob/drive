# One of the United States, or DC: postal code, FIPS code and name.
class State < ApplicationRecord
  include Recoursive

  has_many :counties, dependent: :destroy
  has_many :markets, dependent: :destroy

  validates :code, presence: true, uniqueness: true, format: { with: /\A[A-Z]{2}\z/ }
  validates :fips, presence: true, uniqueness: true, format: { with: /\A\d{2}\z/ }
  validates :name, presence: true, uniqueness: true
end
