Rails.application.configure do
  config.eager_load = false
  config.enable_reloading = true
  config.consider_all_requests_local = true
  config.active_record.migration_error = :page_load

  # A Ruby Native preview arrives over a Cloudflare tunnel, on a host Rails blocks.
  config.hosts << '.trycloudflare.com'
end
