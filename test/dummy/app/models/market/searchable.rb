class Market
  # Widens what a market is searched by, and renames the filter it is narrowed with.
  # An email is worth looking through even though no index covers it, which is what
  # the default search field goes by; and a state reads better as what a market has.
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search_field = 'name_or_email_cont'

      def search_prompt = 'Filter by name or email'

      def filter_fields = { 'state_id_in' => { label: 'Home state' } }
    end
  end
end
