# Base class for the dummy app's controllers, and what supplies their layout.
class ApplicationController < ActionController::Base
private

  # Signs an agent in for this request and every later one in the same session.
  def administrate_as(agent)
    Current.agent = agent
    session[:agent_id] = agent.id
  end
end
