class Place
  # Extends Place with the two things it keeps back and the two it asks to show.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # `place` is a word Unicon has never heard of, and a circle is a poor thing to
      # head a column with. MSA says nothing here on purpose, so the page it draws is
      # what the fallback looks like.
      def recourse_icon = :building

      # Indexed, so it would otherwise be searched, sorted and shown — which is what
      # makes it the honest test of a column a model simply does not want read out.
      def recourse_hidden = :webhook_url

      # Both, in this order: a place is a thing whose age is worth knowing, where a
      # row written once by a migration is not.
      def recourse_timestamps = %i[created_at updated_at]
    end
  end
end
