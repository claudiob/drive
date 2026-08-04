require 'action_controller/railtie'
require 'active_record/railtie'

require 'recourse'

module Dummy
  # Stand-in for a host application, so the gem's tests exercise it the way a
  # real Rails app would rather than by poking at classes directly.
  class Application < Rails::Application
    config.root = File.expand_path('..', __dir__)
    config.load_defaults 8.1
    config.eager_load = false
    config.secret_key_base = 'dummy_secret_key_base'

    # Discard log output: a test run should not leave files behind.
    config.logger = ActiveSupport::Logger.new(IO::NULL)

    # Let a failing request raise into the test rather than being turned into a
    # 500 page, so tests can assert on the exception itself.
    config.action_dispatch.show_exceptions = :none
  end
end
