require 'rails/generators/rails/resource/resource_generator'

require_relative 'associations'
require_relative 'seeds'

module Recourse
  module Generators
    # `rails generate recourse` — everything `rails generate resource` writes, with
    # the route drawn by `recourses` and a seed file, so the gem serves the seven
    # screens for it and there is something to see on them.
    class RecourseGenerator < Rails::Generators::ResourceGenerator
      include Associations, Seeds

      # Templates live beside this class, which is also what tells the parent where to
      # read `--help` from: a USAGE one directory above the source root.
      source_root File.expand_path('templates', __dir__)

      remove_invocation :resource_route

      class_option :seeds, type: :boolean, default: true,
                           desc: 'Add a seed file with a bare row and a filled one'

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

      # A `references` attribute is a `belongs_to`, and a `belongs_to` is two sides of
      # one relationship: the parent gains the counter column and the `has_many` that
      # says what becomes of its children, and the child's own association gains the
      # option that fills the count.
      def add_associations
        counted_attributes.each do |attribute|
          add_counter_column attribute
          count_from_belongs_to attribute
          declare_has_many attribute
        end
      end

      # Two rows to look at: a bare one and a filled one, in a file of their own under
      # `db/seeds`, which `db/seeds.rb` is taught to load.
      def create_seed_file
        return unless options[:seeds]

        template 'seeds.rb', File.join('db/seeds', "#{file_name.pluralize}.rb")
        load_seed_files
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
