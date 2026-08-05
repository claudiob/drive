# A piece of work to be done at a location.
class Job < ApplicationRecord
  include Recoursive

  # The statuses a job moves through. The job...
  STATUSES = [
    :draft # ... has been written down and nothing more (default)
  ]

  belongs_to :location
  has_many :messages, dependent: :nullify

  enum :status, STATUSES.index_by(&:itself)

  validates :title, presence: true
end
