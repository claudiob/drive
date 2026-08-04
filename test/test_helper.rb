ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'recourse'
require_relative 'dummy/config/environment'

require 'minitest/autorun'

# The dummy app's database lives in memory, so it starts every run empty and the
# migrations have to be applied before any model is touched.
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrate
end
