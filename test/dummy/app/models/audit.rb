# What an inspection found at a place, at most one to a place. The singular resource
# the gem finds for itself: nothing but the place names it, so there is no id to look
# up and no controller of this app's own to look one up with.
class Audit < ApplicationRecord
  belongs_to :place

  validates :finding, presence: true
end
