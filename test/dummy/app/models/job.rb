# A piece of work to be done at a location.
class Job < ApplicationRecord
  include Recoursive

  # The statuses a job moves through. The job...
  STATUSES = [
    :draft, # ... has been written down and nothing more (default)
  ]

  belongs_to :location
  belongs_to :specialty, optional: true
  has_many :messages, dependent: :nullify

  enum :status, STATUSES.index_by(&:itself)

  # PLACEHOLDER. What actually makes a job need looking at is not decided yet, so an
  # even id stands in for it — enough to build and seed the screen against, and the one
  # line to replace once the rule is known.
  scope :needing_attention, -> { where 'jobs.id % 2 = 0' }
  scope :claimed_by, lambda { |agent|
    agent ? joins(:location).where(locations: { agent_id: agent }) : none
  }

  validates :title, presence: true
end
