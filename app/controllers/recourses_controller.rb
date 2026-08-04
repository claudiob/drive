# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ApplicationController
  include Pagy::Method

  helper Recourse::Helpers

  # Rows per page. Stated here rather than left to pagy's own matching default.
  PAGE_LIMIT = 20

  # Lists one page of the model the route is named after.
  def index
    @pagy, @resources = pagy resource_class.all, limit: PAGE_LIMIT
  end

private

  def resource_class
    controller_name.classify.constantize
  end
end
