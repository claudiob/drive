Rails.application.configure do
  config.eager_load = false
  config.enable_reloading = true
  config.consider_all_requests_local = true
  config.active_record.migration_error = :page_load

  # A phone on the same Wi-Fi reaches this server by the Mac's Bonjour name. Development
  # allows every IP address but only the one hostname, so without this the device gets a
  # blocked-host page where the app expects JSON, and every list comes up empty.
  config.hosts << '.local'
end
