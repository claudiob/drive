# One county of the United States, identified by its 5-digit FIPS code.
class County < ApplicationRecord
  belongs_to :state
  has_many :zips, dependent: :destroy

  # A county's FIPS code is its identity, assigned once by the census.
  attr_readonly :fips

  validates :fips, :name, presence: true
  validates :fips, uniqueness: true, length: { is: 5 }, format: { with: /\A\d{5}\z/ }
end
