require 'pagy'

require_relative 'recourse/version'
require_relative 'recourse/icons'
require_relative 'recourse/controllers'
require_relative 'recourse/data'
require_relative 'recourse/parameters'
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

  # Columns safe to show: every attribute that is not encrypted.
  def self.visible_columns(model)
    model.column_names - Array(model.encrypted_attributes).map(&:to_s)
  end

  # Columns a user may set: the form offers these and `create` permits these.
  def self.editable_columns(model)
    model.column_names - %w[id created_at updated_at]
  end

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
