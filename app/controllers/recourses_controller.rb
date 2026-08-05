# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ApplicationController
  include Pagy::Method

  helper Recourse::Helpers

  # Lists one page of the model the route is named after.
  def index
    @pagy, @resources = pagy resource_class.all
  end

  # Builds a blank record under the name Rails would use: @contact for contacts.
  def new
    instance_variable_set "@#{controller_name.singularize}", resource_class.new
  end

private

  def resource_class
    controller_name.classify.constantize
  end
end
