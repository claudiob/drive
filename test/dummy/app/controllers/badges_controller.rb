# The numbers the tab bar carries. Two of the three rest on a placeholder rule; see
# `Job.needing_attention`.
class BadgesController < ApplicationController
  # Counts what each tab would want the agent to know about without opening it.
  def index
    render json: {
      jobs: Job.needing_attention.count,
      messages: Contact.with_unread.count,
      contacts: Contact.needing_attention.count,
    }
  end
end
