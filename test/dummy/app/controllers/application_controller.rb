# Base class for the dummy app's controllers, and what supplies their layout.
class ApplicationController < ActionController::Base
  before_action :recognize_the_native_app
  before_action :administrate_as_the_first_agent

private

  # A variant is what lets one route answer a browser and the app with different
  # templates, so `index.html+native.erb` wins in the app and `index.html.erb` out.
  def recognize_the_native_app
    request.variant = :native if native_app?
  end

  # `?native=1` stands in for the app in development only, the way `mock_auth_email`
  # stands in for Google: without it these screens can only be seen in a simulator.
  def native_app?
    return true if Rails.env.development? && params[:native].present?

    request.user_agent.to_s.include? 'Hotwire Native'
  end

  # Stand-in until sign-in is wired up: "Claimed by you" needs someone to be.
  def administrate_as_the_first_agent
    Current.agent = Agent.order(:id).first
  end
end
