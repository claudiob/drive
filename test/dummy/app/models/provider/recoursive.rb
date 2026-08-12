class Provider
  # Says which of a provider's decimals are money and which is a share of it, since
  # `decimal` is all the schema can say about any of them.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_formats
        {
          commission_rate: :percentage, hourly_rate: :price, minimum_price: :price,
        }
      end
    end
  end
end
