# A metropolitan statistical area. Named as the acronym it is, so a page says
# `MSAs` where Rails' own naming says `Msas` — and the table holds one row more
# than a menu will offer, so a form asks for a code instead of listing them.
class MSA < ApplicationRecord
  include Recoursive

  has_many :places, dependent: :destroy

  # Written by the migration that made the table and never again, which is what
  # keeps it off every table the gem draws.
  attr_readonly :fips

  # A letter and four digits, `M0001`: a shape a form can show an example of.
  CODES = /\A[A-Z]\d{4}\z/

  validates :code, presence: true, uniqueness: true, length: { is: 5 },
                   format: { with: CODES }
  validates :fips, presence: true, uniqueness: true, length: { is: 5 }
  validates :name, presence: true
end
