module Recourse
  module Helpers
    # The letter each sidebar link answers to, and where in its title that letter is.
    module Shortcuts
      # The first letter of the title nothing above it has claimed, so `Contacts`
      # answers to C and `Counties`, declared after it, answers to O. Nil where a
      # title has no letter left to give, which leaves that entry without a shortcut.
      def shortcut_index(title, taken)
        index = title.each_char.find_index do |char|
          char.match?(/[a-z]/i) && taken.exclude?(char.downcase)
        end
        taken << title[index].downcase if index

        index
      end

      # The title with that one letter marked, for the overlay to reveal.
      def shortcut_title(title, key)
        marked = tag.span title[key], class: 'recourse-key'

        safe_join [title[0...key], marked, title[(key + 1)..]]
      end
    end
  end
end
