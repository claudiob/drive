require 'active_support'

module Recourse
  # What a resource answers a data client with. Every index `recourses` draws responds
  # to JSON as well as HTML, so a native app needs no controller written for it at all.
  #
  # A host that wants a different shape overrides one of two methods rather than the
  # action: `resource_json` where only a row differs — an extra field, a renamed one —
  # and `index_json` where the payload is not a flat list of records. Both are private,
  # because a public method on a controller is an action.
  module Data
    extend ActiveSupport::Concern

  private

    def index_json
      @resources.map { |record| resource_json record }
    end

    def resource_json(record)
      columns = Recourse.visible_columns resource_class

      record.attributes.slice(*columns).merge path: resource_path(record)
    end

    def resource_path(record)
      return unless Recourse.routed? controller_path, 'show'

      url_for action: :show, id: record, only_path: true
    end
  end
end
