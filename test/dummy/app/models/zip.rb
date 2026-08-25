# A U.S. postal code. Named as the acronym it is, so a page says `ZIPs` where
# Rails' own naming says `Zips` — and the table holds one row more than a menu
# will offer, so a form asks for a code instead of listing them.
class ZIP < ApplicationRecord
  include Recoursive

  has_many :places, dependent: :destroy
  # The other half of a key that names no one table, and what tells the gem that
  # `/zips/1/memos` is this association: a memo outlives what it was about, so the
  # rows stay and the key is emptied.
  has_many :memos, as: :about, dependent: :nullify

  # Written by the migration that made the table and never again, which is what
  # keeps it off every table the gem draws.
  attr_readonly :fips

  # Five digits, `90001`: a shape a form can show an example of.
  CODES = /\A\d{5}\z/

  validates :code, presence: true, uniqueness: true, length: { is: 5 },
                   format: { with: CODES }
  validates :fips, presence: true, uniqueness: true, length: { is: 5 }
  validates :city, presence: true
end
