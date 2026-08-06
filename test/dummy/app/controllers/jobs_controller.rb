# Jobs, with the detail page each row of the native list links to. The gem answers
# every index in JSON already; a row here also names its city, which lives on the
# location rather than the job.
class JobsController < RecoursesController
  # As many as the screen shows before it would need scrolling to reach the next group.
  ATTENTION = 3

  before_action :find_resource, only: :show

  # Shows one job. The gem draws the route but has no `show` action of its own yet.
  def show; end

private

  # Two groups rather than a page: the screen shows what needs looking at, then what
  # the agent has claimed, the way the App Store stacks its sections.
  def index_json
    {
      attention: group(Job.needing_attention.limit(ATTENTION)),
      claimed: group(Job.claimed_by(Current.agent)),
    }
  end

  def group(scope)
    scope.includes(:location).map { |job| resource_json job }
  end

  def resource_json(record)
    super.merge city: record.location.city
  end
end
