module Agents
  # Agents can sign out.
  class SessionsController < ApplicationController
    include Administered

    # Drops the session, then offers Google again rather than a dead end.
    def destroy
      session[:agent_id] = nil
      redirect_to google_auth_url, allow_other_host: true
    end
  end
end
