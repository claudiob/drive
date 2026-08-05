require 'simplecov'

# Started before anything else is required, or the gem's own files load untracked.
SimpleCov.start do
  add_filter '/test/'
  minimum_coverage 100
end

ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'recourse'
require_relative 'dummy/config/environment'

require 'minitest/autorun'

# Create the database on first run, then migrate; both are no-ops afterwards.
begin
  ActiveRecord::Base.lease_connection.verify!
rescue ActiveRecord::NoDatabaseError
  ActiveRecord::Tasks::DatabaseTasks.create_current
end

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrate
end

# Routes load lazily, and `recourses` defines controllers as it draws them, so a
# test that never issues a request would otherwise not see them.
Rails.application.reload_routes_unless_loaded
