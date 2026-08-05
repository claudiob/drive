require 'pagy'

require_relative 'recourse/version'
require_relative 'recourse/icons'
require_relative 'recourse/controllers'
require_relative 'recourse/helpers'
require_relative 'recourse/recoursive'
require_relative 'recourse/engine'

# Namespace for the gem: the routes.rb DSL and the screens it mounts.
module Recourse
  class << self
    # Resources `recourses` has drawn, in the order config/routes.rb lists them.
    attr_reader :declared
  end

  @declared = []

  # Records a resource as declared, keeping order and ignoring a repeated draw.
  def self.declare(name)
    @declared << name.to_s unless @declared.include? name.to_s
  end

  # True when config/routes.rb drew this action for this controller.
  def self.routed?(controller_path, action)
    Rails.application.routes.routes.any? do |route|
      route.defaults[:controller] == controller_path && route.defaults[:action] == action
    end
  end

  # Index path of the first `recourses` that draws one, so a client needing a single
  # entry point never has to name a path itself. Nil when no recourse has an index.
  def self.entry_path
    # Rails 8 draws routes on first use, which is later than a boot-time caller. Not
    # `reload_routes_unless_loaded`: that is `initialized? && ...`, so during an
    # `after_initialize` it answers false and draws nothing.
    Rails.application.routes_reloader.execute_unless_loaded
    name = declared.find { |resource| routed? resource, 'index' }
    return unless name

    Rails.application.routes.url_helpers.url_for controller: "/#{name}", action: :index,
                                                 only_path: true
  end

  # Columns a user may set: the form offers these and `create` permits these.
  def self.editable_columns(model)
    model.column_names - %w[id created_at updated_at]
  end

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
