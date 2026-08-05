# One county of the United States, identified by its 5-digit FIPS code.
class County < ApplicationRecord
  belongs_to :state
  has_many :zips, dependent: :restrict_with_error

  validates :fips, :name, presence: true
  validates :fips, uniqueness: true, length: { is: 5 }, format: { with: /\A\d{5}\z/ }
end
