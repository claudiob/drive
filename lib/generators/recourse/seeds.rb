module Recourse
  module Generators
    # What the seed file `rails generate recourse` writes is made of. Included rather
    # than inherited, and every method private: Thor reads a class's own methods as the
    # tasks it runs, and these are what one of those tasks is written in.
    module Seeds
      # What loads one file per resource, alphabetically. Reorder by hand where one
      # resource's rows need another's to exist first.
      LOADER = "\nDir[Rails.root.join('db/seeds/*.rb')].sort.each { |seeds| load seeds }\n"

      # A value of each column's own type, since a string in every one of them would be
      # a row the database refuses.
      VALUES = {
        integer: '1', float: '1.0', decimal: '1.0', boolean: 'true', date: 'Date.current',
        datetime: 'Time.current', timestamp: 'Time.current', time: 'Time.current',
      }.freeze

    private

      # Once, however many resources are generated: `db/seeds.rb` loads the directory
      # rather than naming every file in it.
      def load_seed_files
        path = File.join destination_root, 'db/seeds.rb'
        create_file 'db/seeds.rb', '' unless File.exist? path
        return if File.exist?(path) && File.read(path).include?(LOADER.strip)

        append_to_file 'db/seeds.rb', LOADER
      end

      # What a row is found by: everything the migration marks `null: false`, or the
      # first attribute where it marks none, so seeding twice finds the rows it made the
      # first time rather than making them again.
      def seed_keys(prefix)
        seed_key_attributes.map { |one| "#{one.name}: #{seed_value one, prefix}" }.join ', '
      end

      # Everything the bare row leaves empty, which is what the filled one fills.
      def seed_rest
        attributes - seed_key_attributes
      end

      def seed_key_attributes
        attributes.select { |one| one.attr_options[:null] == false }.presence ||
          attributes.first(1)
      end

      # A reference reads the first row of what it points at, so a seed run out of order
      # says which table it wanted rather than failing on a nil. A string names the row
      # where it is what the row is found by, and names itself everywhere else.
      def seed_value(attribute, prefix = nil)
        return "#{attribute.name.camelize}.first" if attribute.reference?
        return seed_string attribute, prefix if %i[string text].include? attribute.type

        VALUES.fetch attribute.type, 'nil'
      end

      def seed_string(attribute, prefix)
        return "'#{attribute.human_name}'" unless prefix

        "'#{prefix} #{singular_name.humanize.downcase}'"
      end
    end
  end
end
