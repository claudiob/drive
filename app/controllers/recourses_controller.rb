# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ActionController::Base
  layout :host_layout
  helper_method :resources_name

  # Lists every record of the model the route is named after.
  def index
    @resources = resource_class.all
  end

private

  def resource_class
    controller_name.classify.constantize
  end

  def resources_name
    controller_name.humanize
  end

  def host_layout
    'application' if template_exists?('application', 'layouts')
  end
end
