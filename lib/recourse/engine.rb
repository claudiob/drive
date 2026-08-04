# frozen_string_literal: true

# Loading "rails" rather than "rails/engine" is deliberate: rails/railtie.rb
# calls delegate_missing_to before ActiveSupport's core extensions are in
# place, so requiring rails/engine on its own raises NoMethodError.
require "rails"

module Recourse
  class Engine < ::Rails::Engine
  end
end
