class Memo
  # Extends Memo with the two things it says for itself.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # A memo is written far more often than it is read, and a broadcast on every
      # one of them would redraw an index nobody is looking at.
      def recourse_broadcasts? = false
    end
  end
end
