require 'rails/generators'

require_relative '../declared'
require_relative '../loading'
require_relative 'rows'
require_relative 'shapes'
require_relative 'texts'
require_relative 'values'

module Recourse
  module Generators
    # `rails generate recourse:seed` — a seed file for every model `recourses`
    # serves, so every screen has rows to show and every nullable column is seen
    # both ways.
    class SeedGenerator < Rails::Generators::Base
      include Declared, Loading, Rows, Shapes, Texts, Values

      # Templates live beside this class, which is also what tells the parent where
      # to read `--help` from: a USAGE one directory above the source root.
      source_root File.expand_path('templates', __dir__)

      # One file per model the routes declare, then the line `db/seeds.rb` loads
      # them all with.
      def create_seed_files
        declared_models.each do |model|
          @model = model
          template 'seeds.rb', File.join('db/seeds', "#{model.model_name.plural}.rb")
        end

        load_seed_files
      end
    end
  end
end
