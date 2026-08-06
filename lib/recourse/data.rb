require 'active_support'

module Recourse
  # What a resource answers a data client with. Every index `recourses` draws responds
  # to JSON as well as HTML, so a native app needs no controller written for it at all.
  #
  # A host that wants a different shape overrides one of two methods rather than the
  # action: `resource_json` where only a row differs — an extra field, a renamed one —
  # and `index_json` where the payload is not a flat list of records. Both are private,
  # because a public method on a controller is an action.
  #
  # `create` and `update` answer here too: the record itself on 201 or 200, or its
  # errors on 422, so a native form has something to show against each field.
  #
  # Every row carries the icon its model named, in whichever set the client draws
  # from — so no list of Apple names lives in the app, or of Bootstrap names here.
  module Data
    extend ActiveSupport::Concern

  private

    def index_json
      @resources.map { |record| resource_json record }
    end

    def resource_json(record)
      columns = Recourse.visible_columns resource_class

      record.attributes.slice(*columns).merge path: resource_path(record), icon: icon_name
    end

    # Which set of names the client draws from. The app asks in SF Symbols; anything
    # else is a browser, which has the Bootstrap Icons the console already loads.
    def icon_system
      request.variant.native? ? :ios : :bootstrap
    end

    def icon_name
      Recourse.icon controller_name, icon_system
    end

    def render_saved(record, status)
      render json: resource_json(record), status:
    end

    def render_rejected(record)
      render json: { errors: record.errors.to_hash(true) }, status: :unprocessable_entity
    end

    def resource_path(record)
      return unless Recourse.routed? controller_path, 'show'

      url_for action: :show, id: record, only_path: true
    end
  end
end
