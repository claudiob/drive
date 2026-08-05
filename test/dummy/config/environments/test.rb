Rails.application.configure do
  config.eager_load = false

  # Discard log output: a test run should not leave files behind.
  config.logger = ActiveSupport::Logger.new IO::NULL

  # Let failures raise into the test instead of becoming a 500 page.
  config.action_dispatch.show_exceptions = :none

  # A test posts straight to create, without fetching a form for its token first.
  config.action_controller.allow_forgery_protection = false
end
