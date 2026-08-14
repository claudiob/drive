module Recourse
  module Generators
    # What a seed string is made of: random lengths inside the column's own
    # bounds, a wide alphabet, and no value repeated within its column. Private
    # for the reason `Seeds` is.
    module Texts
      # Letters open and close every string, so none leads or trails blank.
      LETTERS = [*'a'..'z', *'A'..'Z'].freeze

      # The middle draws on more of Unicode — digits, spaces, accents, emoji — so
      # 25 rows put more than one alphabet on the screens. No quote and no
      # backslash: the value lands inside a single-quoted Ruby literal.
      ALPHABET = [
        *LETTERS, *'0'..'9', ' ', ' ', ' ', '&', '-', '.',
        'é', 'ü', 'ñ', 'ø', 'ß', 'Ω', 'ç',
        '✨', '🌵', '🎯', '🦉', '🚀', '🍋',
      ].freeze

      # What an email's local part is made of, plain and lowercase: the shape has
      # to survive a format validator and `downcase: true` encryption unchanged.
      MAILBOX = [*'a'..'z', *'0'..'9'].freeze

    private

      # An email column gets an address and a phone column ten valid digits, since
      # both are the string shapes a model is nearly certain to grow a validator
      # for; everything else is text of a random length in the wide alphabet.
      def seed_string(column)
        seed_unique column do
          next seed_email if column.end_with? 'email'
          next seed_phone if column.end_with? 'phone'

          "'#{seed_text seed_length(column)}'"
        end
      end

      def seed_email
        "'#{Array.new(rand(4..10)) { MAILBOX.sample }.join}@example.com'"
      end

      def seed_phone
        "'555234#{format '%04d', rand(10_000)}'"
      end

      # Random within the bounds the column's own length validator states, and a
      # readable 3..24 where the model states none.
      def seed_length(column)
        options = seed_length_options column
        exact = options[:is]

        rand (exact || options[:minimum] || 3)..(exact || options[:maximum] || 24)
      end

      def seed_length_options(column)
        validator = @model.validators_on(column).find do |one|
          one.is_a? ActiveModel::Validations::LengthValidator
        end

        validator&.options || {}
      end

      def seed_text(length)
        return LETTERS.sample if length < 2

        [LETTERS.sample, *Array.new(length - 2) { ALPHABET.sample }, LETTERS.sample].join
      end

      # The same value twice would leave `find_or_create_by!` finding row one when
      # row two was meant, so a value is drawn again until it is new to its column.
      def seed_unique(column)
        @seed_taken ||= Hash.new { |hash, key| hash[key] = [] }
        taken = @seed_taken["#{@model}/#{column}"]
        value = loop do
          candidate = yield
          break candidate unless taken.include? candidate
        end

        taken << value
        value
      end
    end
  end
end
