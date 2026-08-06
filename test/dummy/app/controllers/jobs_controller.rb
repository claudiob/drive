# Jobs, with the detail page each row of the native list links to.
class JobsController < RecoursesController
  before_action :find_resource, only: :show

  # Lists jobs. The app draws this screen with UIKit's own inset-grouped list rather
  # than markup imitating one, so it asks for the data and not the page.
  def index
    super

    respond_to do |format|
      format.html
      format.json { render json: @resources.map { |job| job_row job } }
    end
  end

  # Shows one job. The gem draws the route but has no `show` action of its own yet.
  def show; end

private

  def job_row(job)
    {
      id: job.id, title: job.title, status: job.status.humanize,
      city: job.location.city, path: job_path(job),
    }
  end
end
