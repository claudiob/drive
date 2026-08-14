require 'rails/generators'

require_relative '../loading'
require_relative 'rows'
require_relative 'values'

module Recourse
  module Generators
    # `rails generate recourse:seed` — a seed file for every model `recourses`
    # serves, so every screen has rows to show and every nullable column is seen
    # both ways.
    class SeedGenerator < Rails::Generators::Base
      include Loading, Rows, Values

      # Templates live beside this class, which is also what tells the parent where
      # to read `--help` from: a USAGE one directory above the source root.
      source_root File.expand_path('templates', __dir__)

      # One file per model the routes declare, then the line `db/seeds.rb` loads
      # them all with.
      def create_seed_files
        # Generators run before a lazy route set is drawn, and drawing is the only
        # thing that tells `recourses` apart from the rest of the routes file.
        Rails.application.reload_routes_unless_loaded

        seed_models.each do |model|
          @model = model
          template 'seeds.rb', File.join('db/seeds', "#{model.model_name.plural}.rb")
        end

        load_seed_files
      end

    private

      def seed_models
        Recourse.declared.filter_map { |path| seed_model path }.uniq
      end

      # A declared resource with no model — drawn for a controller of the host's
      # own — is reported and passed over rather than failing the whole run.
      def seed_model(path)
        Recourse.model path
      rescue Recourse::Error => e
        say_status :skip, e.message
        nil
      end
    end
  end
end
