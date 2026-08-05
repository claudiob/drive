# A street address inside a ZIP, optionally credited to a source and an agent.
class Location < ApplicationRecord
  include Recoursive

  belongs_to :zip
  belongs_to :source, optional: true
  belongs_to :agent, optional: true
  has_many :homes, dependent: :destroy
  has_many :contacts, through: :homes
  has_many :jobs, dependent: :destroy

  encrypts :street
end
