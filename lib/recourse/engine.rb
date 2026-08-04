# Loading rails rather than rails/engine is deliberate: rails/railtie.rb
# calls delegate_missing_to before ActiveSupport's core extensions are in
# place, so requiring rails/engine on its own raises NoMethodError.
require 'rails'

module Recourse
  # Hooks the gem into a host application's boot, so the controllers and views
  # it ships are found without the host copying any files.
  class Engine < ::Rails::Engine
  end
end
