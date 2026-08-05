module Unauthenticated
  # Agents can sign in. This is the redirect URI Google sends them back to.
  class AgentsController < UnauthenticatedController
    # Only agents whose Google account is in this domain may sign in.
    ALLOWED_DOMAIN = '@example.com'

    # Completes the Google flow: Google answers with a code to exchange, or an error.
    def new
      if params[:error]
        @error = params[:error]
      elsif params[:code]
        sign_in
      end
    rescue Yt::HTTPError => e
      @error = e.message
    end

  private

    def sign_in
      unless auth.email.ends_with? ALLOWED_DOMAIN
        return @error = "must authenticate from #{ALLOWED_DOMAIN}"
      end

      administrate_as Agent.find_or_create_by!(email: auth.email)
      redirect_to session.delete(:return_to) || contacts_path, status: :see_other
    end

    # `scope: []` asked Google for an identity and nothing else: no Drive, no YouTube.
    def auth
      @auth ||= Yt::Auth.create redirect_uri: sign_in_url, code: params[:code]
    end
  end
end
