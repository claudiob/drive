# A place signed off, at most one to a place. Nothing to fill in, so it is made by the
# act rather than by a form: the singular resource whose page is either the record or
# the button that makes one.
class Seal < ApplicationRecord
  belongs_to :place
end
