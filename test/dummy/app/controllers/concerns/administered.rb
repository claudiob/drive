# Requires a signed-in agent, sending anyone else to Google first. Include it in a
# controller to protect it: `include Administered`.
module Administered
  extend ActiveSupport::Concern

  included do
    before_action :require_administration
  end

private

  def require_administration
    restore_administration || request_administration
  end

  def restore_administration
    agent = Agent.find_by id: session[:agent_id]

    administrate_as agent if agent
  end

  # Remembers where they were headed, so signing in returns them there.
  def request_administration
    session[:return_to] = request.fullpath
    redirect_to google_auth_url, allow_other_host: true
  end

  # `scope: []` asks Google for an identity and nothing else.
  def google_auth_url
    Yt::Auth.url_for redirect_uri: sign_in_url, scope: []
  end
end
