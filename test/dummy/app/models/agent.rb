# Someone acting on the host app's behalf, identified by a unique email.
class Agent < ApplicationRecord
  encrypts :email, deterministic: true, downcase: true

  validates :email, presence: true, uniqueness: true
end
