# Jobs, with the detail page each row of the native list links to. The gem answers
# every index in JSON already; a row here also names its city, which lives on the
# location rather than the job.
class JobsController < RecoursesController
  before_action :find_resource, only: :show

  # Shows one job. The gem draws the route but has no `show` action of its own yet.
  def show; end

private

  def resource_json(record)
    super.merge city: record.location.city
  end
end
