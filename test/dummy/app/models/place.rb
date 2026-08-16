# Everything a screen can be asked to draw, in one model: a column of every kind the
# gem formats, a foreign key that is typed beside one that is picked, an enum, two
# encrypted columns, and one the model keeps off every page.
class Place < ApplicationRecord
  include Phonable, Recoursive

  # What a place is at, one per line saying what that state means.
  STATUSES = [
    :draft, # written down and nothing more (default)
    :open, # taking bookings
    :closed, # taking none, and not coming back
  ].freeze

  # Lower case, digits and hyphens, starting and ending on a character: what a URL
  # can carry without escaping. A form reads this back as its `pattern`.
  SLUGS = /\A[a-z0-9]+(-[a-z0-9]+)*\z/

  enum :status, STATUSES.index_by(&:itself)

  # 101 of them, so a form asks for a code; three teams, so a form lists them.
  belongs_to :msa, counter_cache: true
  belongs_to :team, counter_cache: true, touch: true
  # The parent a nested route answers, and optional, so a place can stand alone.
  # Counted, which is what earns the person's card a tab reading `3 places`.
  belongs_to :person, optional: true, counter_cache: true

  # Money and a share of it, told apart by their types and not by their names.
  attribute :hourly_rate, :price
  attribute :commission_rate, :percentage

  # Queried and unique, so its ciphertext has to be the same every write.
  encrypts :secret, deterministic: true
  # Neither, so it need not be.
  encrypts :notes

  validates :name, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  # A non-null boolean is included in the two, never present: `presence` rejects
  # `false` along with nil.
  validates :active, inclusion: { in: [true, false] }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
                     allow_nil: true

  with_options format: { with: SLUGS, message: 'is lower case, digits and hyphens' } do
    validates :slug, presence: true, uniqueness: true, length: { maximum: 20 }
  end
end
