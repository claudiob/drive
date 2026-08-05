# A street address inside a ZIP, optionally credited to a source and an agent.
class Location < ApplicationRecord
  belongs_to :zip
  belongs_to :source, optional: true
  belongs_to :agent, optional: true

  encrypts :street
end
