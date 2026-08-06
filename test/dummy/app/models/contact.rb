# Someone the host app can reach, identified by a unique 10-digit phone number.
class Contact < ApplicationRecord
  include Emailable, Phonable

  # Letter a contact files under. Plain `name`, because `surname` is encrypted
  # non-deterministically: the database cannot order, group or match that at all.
  INITIAL = Arel.sql "case when name ~ '^[A-Za-z]' then upper(left(name, 1)) else '#' end"

  # '#' sorts ahead of 'A' in ASCII, and the unnamed belong at the end of the list.
  NAMED_FIRST = Arel.sql "case when name ~ '^[A-Za-z]' then 0 else 1 end"

  has_many :homes, dependent: :destroy
  has_many :locations, through: :homes
  has_many :messages, dependent: :destroy

  encrypts :phone, deterministic: true
  encrypts :surname

  validates :phone, presence: true, uniqueness: true

  # PLACEHOLDER, like `Job.needing_attention`: the real rule is not decided yet.
  scope :needing_attention, -> { where 'contacts.id % 2 = 0' }
  scope :alphabetical, -> { order NAMED_FIRST, INITIAL, :name, :id }
  scope :with_unread, -> { where id: Message.unread.select(:contact_id) }
  # Nobody signed in claims nobody, rather than every unclaimed contact.
  scope :claimed_by, ->(agent) { agent ? where(id: claimed_by_ids(agent)) : none }
  # `NOT IN` would answer nothing at all if the subquery held a NULL. It cannot:
  # `homes.contact_id` is `null: false`.
  scope :unclaimed, -> { where.not id: claimed_ids }

  # Contact ids one agent has claimed, through the location of one of their homes.
  def self.claimed_by_ids(agent)
    Home.joins(:location).where(locations: { agent_id: agent }).select :contact_id
  end

  # Contact ids any agent at all has claimed, which is what leaves the rest unclaimed.
  def self.claimed_ids
    Home.joins(:location).where.not(locations: { agent_id: nil }).select :contact_id
  end

  # What to call a contact on screen: their name, or their number when they have none.
  def display_name
    [name, surname].compact_blank.join(' ').presence ||
      ActiveSupport::NumberHelper.number_to_phone(phone)
  end

  # The one or two letters an avatar circle shows.
  def initials
    [name, surname].compact_blank.map(&:first).join.upcase.presence || '#'
  end

  # The section a contact files under, matching what `INITIAL` computes in SQL.
  def initial
    name.to_s.match?(/\A[A-Za-z]/) ? name.first.upcase : '#'
  end
end
