class Contact
  # How a contact is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon
        { bootstrap: :'person-rolodex', ios: :'person.crop.circle', android: :contacts }
      end
    end
  end
end
