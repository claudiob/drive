# Someone acting on the host app's behalf, identified by a unique email.
class Agent < ApplicationRecord
  include Emailable, Recoursive

  has_many :locations, dependent: :nullify

  before_validation :name_from_email, if: -> { name.blank? }

  validates :email, presence: true, uniqueness: true

private

  def name_from_email
    self.name = email.to_s.split('@').first&.humanize
  end
end
