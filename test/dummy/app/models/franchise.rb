# One of the franchises a provider may belong to, with its own lead pipeline.
class Franchise < ApplicationRecord
  has_many :providers, dependent: :nullify

  encrypts :key

  validates :name, presence: true, uniqueness: true
  # The one pattern in this app that is neither all digits nor has a sample to show,
  # so the title a browser reads is read off the pattern itself: `a-0000`.
  validates :key, format: { with: /\A[a-z]-\d{4}\z/ }, allow_nil: true
  validates :multiple, inclusion: { in: [true, false], message: 'must be true or false' }
end
