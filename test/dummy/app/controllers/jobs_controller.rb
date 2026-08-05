# Jobs, with the detail page each row of the native list links to.
class JobsController < RecoursesController
  before_action :find_resource, only: :show

  # Shows one job. The gem draws the route but has no `show` action of its own yet.
  def show; end
end
