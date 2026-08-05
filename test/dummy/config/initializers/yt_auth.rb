# Google credentials for signing agents in. Both come from the credentials file, so
# neither is ever committed: `bin/rails credentials:edit` and see README-AGENTS.md.
Yt.configure do |config|
  config.client_id = Rails.application.credentials.dig :google_oauth, :client_id
  config.client_secret = Rails.application.credentials.dig :google_oauth, :client_secret

  # Stands in for the round trip to Google, so the flow can be walked through with no
  # keys at all. Never outside development: it will sign anyone in as this address.
  config.mock_auth_email = 'dev@example.com' if Rails.env.development?
end
