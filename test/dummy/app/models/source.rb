# Where the host app learned about something, identified by name.
class Source < ApplicationRecord
  include Recoursive

  has_many :locations, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
