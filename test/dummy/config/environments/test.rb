Rails.application.configure do
  config.eager_load = false

  # Discard log output: a test run should not leave files behind.
  config.logger = ActiveSupport::Logger.new IO::NULL

  # Let failures raise into the test instead of becoming a 500 page.
  config.action_dispatch.show_exceptions = :none
end
