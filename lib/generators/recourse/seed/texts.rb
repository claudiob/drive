module Recourse
  module Generators
    # What free seed text is made of: words of evenly distributed lengths, joined
    # by single spaces into the column's own bounds. Private for the reason
    # `Seeds` is.
    module Texts
      # Letters open and close every word, so none leads or trails blank.
      LETTERS = [*'a'..'z', *'A'..'Z'].freeze

      # The middle draws on more of Unicode — digits, accents, emoji — so 25 rows
      # put more than one alphabet on the screens. No quote and no backslash: the
      # value lands inside a single-quoted Ruby literal. No space either; a space
      # is what joins words, never part of one.
      ALPHABET = [
        *LETTERS, *'0'..'9', '&', '-', '.',
        'é', 'ü', 'ñ', 'ø', 'ß', 'Ω', 'ç',
        '✨', '🌵', '🎯', '🦉', '🚀', '🍋',
      ].freeze

      # How long one word may be, drawn evenly, so no string carries a longer
      # unbroken run and a one-letter word is as likely as a fifteen-letter one.
      WORDS = 1..15

    private

      # A column pinned to an exact length holds a code, and a code is one solid
      # word; everything else reads as words.
      def seed_words(column)
        length = seed_length column
        return seed_word length if seed_length_options(column)[:is]

        seed_text length
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

      # Words joined by single spaces, landing exactly on `length`: a draw that
      # would overshoot, or leave one character of room — a space with nothing
      # after it — stretches to end the string instead.
      def seed_text(length)
        words = []
        remaining = length
        while remaining.positive?
          drawn = rand WORDS
          drawn = remaining if drawn >= remaining - 1
          words << seed_word(drawn)
          remaining -= drawn + 1
        end

        words.join ' '
      end

      def seed_word(length)
        return LETTERS.sample if length < 2

        [LETTERS.sample, *Array.new(length - 2) { ALPHABET.sample }, LETTERS.sample].join
      end
    end
  end
end
