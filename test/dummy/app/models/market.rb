# One of the markets the host app operates in, identified by name.
class Market < ApplicationRecord
  has_many :zips, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :zip, format: { with: /\A\d{5}\z/ }, allow_blank: true
end
