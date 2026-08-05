# rails/engine alone raises NoMethodError: railtie.rb calls delegate_missing_to too early.
require 'rails'

require_relative 'routes'

module Recourse
  # Hooks the gem into a host app's boot so its controllers and views are found.
  class Engine < ::Rails::Engine
    # Initializers all run before routes are drawn, so `recourses` exists in time.
    initializer 'recourse.routes' do
      ActionDispatch::Routing::Mapper.include Routes
    end

    # Serves the vendored Bootstrap, since a host may run no asset pipeline at all.
    # The prefix keeps its slash: without it `/recourses` would be served as a file.
    initializer 'recourse.assets' do |app|
      app.middleware.use Rack::Static, urls: %w[/recourse/], root: Engine.root.join('vendor')
    end
  end
end
