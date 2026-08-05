# Someone acting on the host app's behalf, identified by a unique email.
class Agent < ApplicationRecord
  include Emailable

  validates :email, presence: true, uniqueness: true
end
