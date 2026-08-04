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
  end
end
