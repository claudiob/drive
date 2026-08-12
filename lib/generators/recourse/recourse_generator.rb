require 'rails/generators/rails/resource/resource_generator'

module Recourse
  module Generators
    # `rails generate recourse` — everything `rails generate resource` writes, with
    # the route drawn by `recourses`, so the gem serves the seven screens for it.
    class RecourseGenerator < Rails::Generators::ResourceGenerator
      remove_invocation :resource_route

      # Where `--help` reads from. The parent looks for a USAGE beside a source root,
      # and this generator has no templates of its own to need one.
      def self.usage_path = File.expand_path('USAGE', __dir__)

      # The generated controller inherits `RecoursesController`. A controller of the
      # host's own is what `Controllers.define_missing` steps aside for, so the
      # `ApplicationController` one `resource` writes would leave the resource with
      # no actions at all — the opposite of what generating it was for.
      # `in: :recourse` sends the hook's lookup to this gem's own controller
      # generator rather than Rails', which is what changes the parent class. It is
      # the base name of the class declaring the hook, so the parent's own
      # declaration resolved `rails:controller` and this one resolves
      # `recourse:controller`.
      #
      # Invoked with arguments and nothing else, exactly as the parent invokes it:
      # handing `invoke` an options hash is what stops `--pretend`, `--no-helper`
      # and every other switch meant for the controller from reaching it.
      hook_for :resource_controller, in: :recourse, required: true do |controller|
        invoke controller, [controller_name, options[:actions]]
      end

      # The line this generator exists for. `namespace:` nests it the way the routes
      # were asked for, so `rails generate recourse admin/market` draws `recourses
      # :markets` inside `namespace :admin`.
      def add_recourse_route
        return if options[:actions].present?

        route "recourses :#{file_name.pluralize}", namespace: regular_class_path
      end
    end
  end
end
