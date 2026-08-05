# rails/engine alone raises NoMethodError: railtie.rb calls delegate_missing_to too early.
require 'rails'

require_relative 'routes'

module Recourse
  # Hooks the gem into a host app's boot so its controllers and views are found.
  class Engine < ::Rails::Engine
    # Prefix the gem answers for with a file. `Rack::Static` matches on
    # `start_with?`, so dropping the slash would swallow `/recourses` itself.
    STATIC_URLS = %w[/recourse/].freeze

    # Initializers all run before routes are drawn, so `recourses` exists in time.
    initializer 'recourse.routes' do
      ActionDispatch::Routing::Mapper.include Routes
    end

    # Serves what a page needs, since a host may run no asset pipeline at all. The
    # prefix keeps its slash: without it `/recourses` would be served as a file.
    # Vendored files answer first and cascade, so our own JavaScript shares the URL.
    initializer 'recourse.assets' do |app|
      app.middleware.use Rack::Static, urls: STATIC_URLS, root: Engine.root.join('vendor'),
                                       cascade: true
      app.middleware.use Rack::Static, urls: STATIC_URLS, root: Engine.root.join('app/javascript')
    end
  end
end
