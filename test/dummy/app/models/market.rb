# One of the markets the host app operates in, identified by name.
class Market < ApplicationRecord
  has_many :zips, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
