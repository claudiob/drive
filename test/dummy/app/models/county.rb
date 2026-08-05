# One county of the United States, identified by its 5-digit FIPS code.
class County < ApplicationRecord
  belongs_to :state
  has_many :zips, dependent: :restrict_with_error

  validates :fips, presence: true, uniqueness: true, format: { with: /\A\d{5}\z/ }
  validates :name, presence: true
end
