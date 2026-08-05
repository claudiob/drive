require_relative 'boot'

require 'action_controller/railtie'
require 'active_record/railtie'

# No `Bundler.require` here, so an engine that a Gemfile line would load elsewhere
# has to be named: without this, `/native/config.json` is a 404. Propshaft comes
# first because ruby_native only registers its stylesheet if `config.assets` exists.
require 'propshaft'
require 'ruby_native'

require 'recourse'

module Dummy
  # Stand-in for a host app, so tests exercise the gem through a booting Rails.
  class Application < Rails::Application
    config.root = File.expand_path '..', __dir__
    config.load_defaults 8.1
    config.secret_key_base = 'dummy_secret_key_base'
    config.time_zone = 'Eastern Time (US & Canada)'

    # No schema.rb: loading one stamps the backfills as done and skips the data.
    config.active_record.dump_schema_after_migration = false

    # Action View logs a line per partial, which buries the request itself.
    config.action_view.logger = nil

    # Bootstrap wants `is-invalid` on the control and the message beside it, which
    # Rails' default `field_with_errors` wrapper gives neither. Labels pass through.
    config.action_view.field_error_proc = proc do |html_tag, instance|
      next html_tag unless html_tag.include? 'form-control'

      described = "#{html_tag[/id="([^"]*)"/, 1]}_error"
      # A SafeBuffer escapes whatever is inserted, so the attribute is built safe.
      aria = safe_join [' ', tag.attributes('aria-describedby': described)]
      html_tag.insert html_tag.index('form-control'), 'is-invalid '
      html_tag.insert html_tag.index(' '), aria
      messages = instance.error_message.to_sentence.upcase_first

      safe_join [html_tag, tag.small(messages, class: 'invalid-feedback', id: described)]
    end

    # Throwaway keys, so a model can encrypt an attribute and prove it is hidden.
    config.active_record.encryption.primary_key = 'dummy_primary_key_for_the_dummy_app'
    config.active_record.encryption.deterministic_key = 'dummy_deterministic_key_for_dummy'
    config.active_record.encryption.key_derivation_salt = 'dummy_key_derivation_salt_for_it'
    config.active_record.encryption.support_unencrypted_data = true
  end
end
