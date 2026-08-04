require_relative 'boot'

require 'action_controller/railtie'
require 'active_record/railtie'

require 'recourse'

module Dummy
  # Stand-in for a host app, so tests exercise the gem through a booting Rails.
  class Application < Rails::Application
    config.root = File.expand_path '..', __dir__
    config.load_defaults 8.1
    config.secret_key_base = 'dummy_secret_key_base'
    config.time_zone = 'Eastern Time (US & Canada)'

    # Action View logs a line per partial, which buries the request itself.
    config.action_view.logger = nil

    # Throwaway keys, so a model can encrypt an attribute and prove it is hidden.
    config.active_record.encryption.primary_key = 'dummy_primary_key_for_the_dummy_app'
    config.active_record.encryption.deterministic_key = 'dummy_deterministic_key_for_dummy'
    config.active_record.encryption.key_derivation_salt = 'dummy_key_derivation_salt_for_it'
    config.active_record.encryption.support_unencrypted_data = true
  end
end
