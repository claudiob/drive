require 'action_controller/railtie'
require 'active_record/railtie'

require 'recourse'

module Dummy
  # Stand-in for a host app, so tests exercise the gem through a booting Rails.
  class Application < Rails::Application
    config.root = File.expand_path('..', __dir__)
    config.load_defaults 8.1
    config.eager_load = false
    config.secret_key_base = 'dummy_secret_key_base'

    # Discard log output: a test run should not leave files behind.
    config.logger = ActiveSupport::Logger.new(IO::NULL)

    # Let failures raise into the test instead of becoming a 500 page.
    config.action_dispatch.show_exceptions = :none
  end
end
