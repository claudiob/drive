# A key-value pair the host app looks up by key, typed by its kind.
class Setting < ApplicationRecord
  include Recoursive

  # The kinds a setting's value may be typed as, and the field it draws in a form.
  KINDS = [
    :number, # a plain number (default)
    :text, # a short string
    :file, # a URL or path to an uploaded file
    :color, # a hex color value
    :choice, # one of a fixed list of options
    :boolean, # true or false
  ]

  belongs_to :agent, optional: true

  enum :kind, KINDS.index_by(&:itself)

  validates :key, presence: true, uniqueness: true
  validates :value, presence: true
end
