# One of the franchises a provider may belong to, with its own lead pipeline.
class Franchise < ApplicationRecord
  has_many :providers, dependent: :nullify

  encrypts :key

  validates :name, presence: true, uniqueness: true
  validates :multiple, inclusion: { in: [true, false], message: 'must be true or false' }
end
