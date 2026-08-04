require_relative 'administered'
require_relative 'recourse/version'
require_relative 'recourse/engine'

# Namespace for the gem: the routes.rb DSL and the screens it mounts.
module Recourse
  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
