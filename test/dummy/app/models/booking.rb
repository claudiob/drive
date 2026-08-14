# A request for work at a ZIP, from a contact, possibly routed through an app.
class Booking < ApplicationRecord
  include Recoursive

  # The statuses a booking moves through, roughly in the order it moves through them.
  STATUSES = [
    :draft, # written down and nothing more (default)
    :upcoming, # scheduled to go out soon
    :engaged, # a provider has responded
    :matched, # a provider has been chosen
    :lost, # no provider took it
    :scheduled, # a time has been set
    :fulfilled, # the work is done
    :dropped, # the contact walked away
    :unreachable, # the contact could not be reached
    :liked, # the contact rated it well
    :disliked, # the contact rated it poorly
    :expired, # it went unanswered too long
  ]

  belongs_to :app, optional: true, counter_cache: true, touch: true
  belongs_to :contact, counter_cache: true, touch: true
  belongs_to :provider, optional: true, counter_cache: true, touch: true
  belongs_to :specialty, optional: true, counter_cache: true, touch: true
  belongs_to :zip, counter_cache: true, touch: true

  enum :status, STATUSES.index_by(&:itself)

  encrypts :street

  validates :summary, presence: true
  validates :quote_count, presence: true

  with_options inclusion: { in: [true, false], message: 'must be true or false' } do
    validates :subscribed
  end
end
