# Something said to a contact or heard from one, sometimes about a job.
class Message < ApplicationRecord
  belongs_to :contact
  belongs_to :job, optional: true

  validates :content, presence: true

  # `presence` rejects false, so a required boolean is asked for this way instead. The
  # default message reads "is not included in the list", which explains nothing here.
  validates :inbound, inclusion: { in: [true, false], message: 'must be true or false' }
end
