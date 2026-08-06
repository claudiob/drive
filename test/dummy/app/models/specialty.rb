# A trade a job can call for, identified by name.
class Specialty < ApplicationRecord
  include Recoursive

  has_many :jobs, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
