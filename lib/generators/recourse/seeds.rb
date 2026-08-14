module Recourse
  module Generators
    # What the seed file `rails generate recourse` writes is made of. Included rather
    # than inherited, and every method private: Thor reads a class's own methods as the
    # tasks it runs, and these are what one of those tasks is written in.
    module Seeds
      # A value of each column's own type, since a string in every one of them would be
      # a row the database refuses.
      VALUES = {
        integer: '1', float: '1.0', decimal: '1.0', boolean: 'true', date: 'Date.current',
        datetime: 'Time.current', timestamp: 'Time.current', time: 'Time.current',
      }.freeze

    private

      # The bare row is found by everything it must have to save at all.
      def bare_seed_keys
        seed_pairs seed_key_attributes, 'Bare'
      end

      # The filled row by the same, and by one more where that is not enough to tell the
      # two apart — an author is the same author in both.
      def filled_seed_keys
        seed_pairs seed_key_attributes + Array(seed_marker), 'Everything'
      end

      # What a row must have: whatever the migration marks `null: false`, and every
      # reference, since `belongs_to` requires one unless an app has said otherwise. A
      # post with no author will not save, however bare it is meant to be. Where a row
      # must have nothing, the first attribute stands in: two rows a seed cannot tell
      # apart are two more rows every time it runs.
      def seed_key_attributes
        required = attributes.select { |one| one.attr_options[:null] == false || one.required? }

        required.presence || attributes.first(1)
      end

      # A reference reads the same row in both rows and a number the same number, so
      # where nothing a row must have carries a name, the first optional attribute joins
      # the filled row's key. That is what leaves `find_or_create_by!` able to find each.
      def seed_marker
        return if seed_key_attributes.any? { |one| seed_string? one }

        (attributes - seed_key_attributes).first
      end

      # Everything neither row is found by, which is what the filled one fills.
      def seed_filled_attributes
        attributes - seed_key_attributes - Array(seed_marker)
      end

      def seed_pairs(list, prefix)
        list.map { |one| "#{one.name}: #{seed_value one, prefix}" }.join ', '
      end

      # A reference reads the first row of what it points at, so a seed run out of order
      # says which table it wanted rather than failing on a nil. A string names the row
      # where it is what the row is found by, and names itself everywhere else.
      def seed_value(attribute, prefix = nil)
        return "#{attribute.name.camelize}.first" if attribute.reference?
        return seed_string attribute, prefix if seed_string? attribute

        VALUES.fetch attribute.type, 'nil'
      end

      def seed_string(attribute, prefix)
        return "'#{(prefix || 'Everything').downcase}@example.com'" if seed_email? attribute
        return "'#{attribute.human_name}'" unless prefix

        "'#{prefix} #{singular_name.humanize.downcase}'"
      end

      def seed_string?(attribute)
        %i[string text].include? attribute.type
      end

      # An address rather than a word, since it is the one string shape a model is
      # nearly certain to grow a validator for.
      def seed_email?(attribute)
        attribute.name.end_with? 'email'
      end
    end
  end
end
