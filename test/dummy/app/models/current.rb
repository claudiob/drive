# Attributes every request can reach, reset between requests by Rails itself.
class Current < ActiveSupport::CurrentAttributes
  # The signed-in agent, set when a session is restored or a sign-in completes.
  attribute :agent
end
