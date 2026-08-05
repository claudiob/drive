require 'pagy'

require_relative 'recourse/version'
require_relative 'recourse/icons'
require_relative 'recourse/controllers'
require_relative 'recourse/helpers'
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

  # Columns a user may set: the form offers these and `create` permits these.
  def self.editable_columns(model)
    model.column_names - %w[id created_at updated_at]
  end

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
