require 'net/http'

# Address suggestions from Google, proxied rather than called from the device: the key
# belongs on the server, where it can be rotated without shipping a build.
class PlacesController < ApplicationController
  # Where Google answers autocomplete queries.
  ENDPOINT = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'

  # Lists what Google thinks the query might be, or nothing at all when it cannot ask.
  def index
    render json: { predictions: predictions }
  end

private

  def predictions
    return [] if params[:q].blank? || key.blank?

    body = Net::HTTP.get URI(ENDPOINT + "?#{query}")
    JSON.parse(body).fetch('predictions', []).map { |prediction| suggestion prediction }
  rescue StandardError
    # A suggestion nobody can offer is not an error worth failing the screen over.
    []
  end

  def suggestion(prediction)
    format = prediction['structured_formatting'] || {}

    {
      id: prediction['place_id'], title: format['main_text'] || prediction['description'],
      detail: format['secondary_text'],
    }
  end

  def query
    { input: params[:q], key:, types: 'address', components: 'country:us' }.to_query
  end

  def key
    Rails.application.credentials.dig :google_maps, :api_key
  end
end
