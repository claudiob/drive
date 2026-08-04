# Loading rails rather than rails/engine is deliberate: rails/railtie.rb
# calls delegate_missing_to before ActiveSupport's core extensions are in
# place, so requiring rails/engine on its own raises NoMethodError.
require 'rails'

require_relative 'routes'

module Recourse
  # Hooks the gem into a host application's boot, so the controllers and views
  # it ships are found without the host copying any files.
  class Engine < ::Rails::Engine
    # Runs before the host draws its routes, which happens after every
    # initializer, so `recourses` is defined by the time routes.rb is read.
    initializer 'recourse.routes' do
      ActionDispatch::Routing::Mapper.include Routes
    end
  end
end
