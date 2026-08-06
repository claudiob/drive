# Something said to a contact or heard from one, sometimes about a job.
class Message < ApplicationRecord
  include Recoursive

  # The latest message per contact, and how many of theirs are still unread. Postgres
  # runs a window function before `distinct on`, so both come from the one pass.
  LATEST_PER_CONTACT = <<~SQL.squish
    distinct on (contact_id) messages.id, messages.contact_id, messages.content,
      messages.media_urls, messages.inbound, messages.read_at, messages.created_at,
      count(*) filter (where inbound and read_at is null)
        over (partition by contact_id) as unread_count
  SQL

  belongs_to :contact
  belongs_to :job, optional: true

  # Only something heard from a contact can be waiting to be read.
  scope :unread, -> { where inbound: true, read_at: nil }
  scope :conversations, lambda {
    latest = unscoped.select(LATEST_PER_CONTACT).order :contact_id, created_at: :desc

    # `includes` rather than a lookup per row: the author and avatar need the contact.
    from(latest, :messages).order(created_at: :desc).includes :contact
  }

  # Either alone is enough; a message with neither says nothing at all. The message
  # reads as "Content or media is required", so it names the way out it does not check.
  validates :content, presence: { message: 'or media is required' },
                      unless: -> { media_urls.present? }

  # `presence` rejects false, so a required boolean is asked for this way instead. The
  # default message reads "is not included in the list", which explains nothing here.
  validates :inbound, inclusion: { in: [true, false], message: 'must be true or false' }
end
