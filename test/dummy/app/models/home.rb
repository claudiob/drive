# Where a contact lives, and in what capacity.
class Home < ApplicationRecord
  include Recoursive

  # The parts a contact plays in a home. The contact...
  ROLES = [
    :homeowner, # ... owns it (default)
  ]

  belongs_to :contact
  belongs_to :location

  enum :role, ROLES.index_by(&:itself)
end
