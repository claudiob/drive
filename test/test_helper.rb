ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'recourse'
require_relative 'dummy/config/environment'

require 'minitest/autorun'

# Create the dummy app's database the first time the suite runs, then bring it up
# to date. Both steps are no-ops on every run after that.
begin
  ActiveRecord::Base.lease_connection.verify!
rescue ActiveRecord::NoDatabaseError
  ActiveRecord::Tasks::DatabaseTasks.create_current
end

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrate
end
