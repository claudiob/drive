# Where the host app learned about something, identified by name.
class Source < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
