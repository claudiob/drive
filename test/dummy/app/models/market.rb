# One of the markets the host app operates in, identified by name.
class Market < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
