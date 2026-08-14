module Recourse
  module Generators
    # Teaches `db/seeds.rb` to load the files under `db/seeds`, once, however many
    # generators write one. Private for the reason `Seeds` is.
    module Loading
      # What loads one file per resource, alphabetically. Reorder by hand where one
      # resource's rows need another's to exist first.
      LOADER = "\nDir[Rails.root.join('db/seeds/*.rb')].sort.each { |seeds| load seeds }\n"

    private

      # Once, however many resources are generated: `db/seeds.rb` loads the directory
      # rather than naming every file in it.
      def load_seed_files
        path = File.join destination_root, 'db/seeds.rb'
        create_file 'db/seeds.rb', '' unless File.exist? path
        return if File.exist?(path) && File.read(path).include?(LOADER.strip)

        append_to_file 'db/seeds.rb', LOADER
      end
    end
  end
end
