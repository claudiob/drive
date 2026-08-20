require 'active_support'

module Recourse
  # A resource with no rows of its own: a page assembled out of other models' records —
  # the messages a conversation comes to, a digest of a week — which the gem asks the
  # same questions as a table. Everything a table answers from its columns and its
  # associations is answered here as the nothing an aggregate has, so a host writing one
  # includes this and says only what its own is called and drawn with.
  #
  # A concern rather than a module to extend, so a class says `include Recourse::Aggregate`
  # once: the class methods arrive with it, and so does the naming a gem needs to title a
  # class that has no table to read a name from.
  module Aggregate
    extend ActiveSupport::Concern

    included do
      # `model_name` is what every title, crumb and tab reads a resource's word from,
      # and a class with no table has nowhere else to get one.
      extend ActiveModel::Naming
    end

    class_methods do
      # No columns, so no cell, no field and no value: what such a page draws is the
      # host's own template, and there is nothing here for the gem to lay out.
      def column_names = []

      # Nothing to keep off a screen that draws none of it.
      def recourse_hidden = []

      # And nothing to put back on one.
      def recourse_displayed = []

      # No counter cache, there being no association to count and no column to hold it.
      def recourse_counters = {}

      # No key to follow: a key points at a row, and an aggregate keeps none — so
      # nothing to label, to list, to filter by or to eager-load.
      def recourse_references = []

      # And no polymorphic key either, for the same reason.
      def recourse_reference_types = []

      # What names one of its rows, defaulted the way a model's is so that including
      # this is enough on its own.
      def recourse_label = :name

      # And what it is drawn with, which Unicon reads off the class's own name.
      def recourse_icon = model_name.singular.to_sym
    end
  end
end
