# One of the markets the host app operates in, identified by name.
class Market < ApplicationRecord
  include Recoursive

  belongs_to :state
  has_many :zips, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true
  validates :zip, format: { with: /\A\d{5}\z/ }, length: { is: 5 }, allow_blank: true
  validates :color, format: { with: /\A#[0-9a-f]{6}\z/ }, allow_blank: true
end
