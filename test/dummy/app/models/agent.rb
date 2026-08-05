# Someone acting on the host app's behalf, identified by a unique email.
class Agent < ApplicationRecord
  include Emailable, Recoursive

  validates :email, presence: true, uniqueness: true
end
