# A depth somebody measured, and the reading taken before it. The table past
# MENU_LIMIT whose label is not a word, which is what leaves a key pointing here
# with neither a menu to pick from nor a search box to be typed into.
class Reading < ApplicationRecord
  include Recoursive

  belongs_to :previous_reading, optional: true, class_name: 'Reading'

  validates :depth, presence: true
end
