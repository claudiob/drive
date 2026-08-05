# Attributes scoped to one request, so a screen can ask who is looking at it.
class Current < ActiveSupport::CurrentAttributes
  attribute :agent
end
