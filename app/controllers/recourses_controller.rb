# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ActionController::Base
  # Lists every record of the model the route is named after.
  def index
    @resources = resource_class.all
  end

private

  def resource_class
    controller_name.classify.constantize
  end
end
