# Shared behavior for models that store a phone number: strips it down to its
# digits on assignment, then accepts it only if it is a valid 10-digit number.
module Phonable
  extend ActiveSupport::Concern

  # Ten digits, where neither the area code nor the exchange code may start
  # with 0 or 1, which is what makes 555-1234 numbers unassignable.
  NORTH_AMERICAN_PHONES = /\A[2-9]\d{2}[2-9]\d{6}\z/

  included do
    normalizes :phone, with: ->(phone) { phone.delete('^0-9').delete_prefix '1' }
    validates :phone, format: { with: NORTH_AMERICAN_PHONES,
                                message: 'is not a valid phone number' },
                      allow_nil: true
  end
end
