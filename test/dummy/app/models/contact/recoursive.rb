class Contact
  # When someone first reached the app is part of who they are to it.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_timestamps = %i[created_at]
    end
  end
end
