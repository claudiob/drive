# Something said to a contact or heard from one, sometimes about a job.
class Message < ApplicationRecord
  include Mediable

  belongs_to :contact
  belongs_to :job, optional: true

  # Either alone is enough; a message with neither says nothing at all. The message
  # reads as "Content or media is required", so it names the way out it does not check.
  validates :content, presence: { message: 'or media is required' },
                      unless: -> { media_urls.present? }

  # `presence` rejects false, so a required boolean is asked for this way instead. The
  # default message reads "is not included in the list", which explains nothing here.
  validates :inbound, inclusion: { in: [true, false], message: 'must be true or false' }
end
