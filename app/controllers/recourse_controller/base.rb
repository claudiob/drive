module RecourseController
  # Everything a recoursed screen does, in a class of its own so a host can put
  # its own behavior above it — `class RecoursesController < RecourseController::Base`
  # with a `before_action :authenticate!` guards every screen the gem serves.
  class Base < ApplicationController
    include Pagy::Method, Recourse::ParentResolution, Recourse::ReferenceResolution,
            Recourse::ResourceResolution

    helper Recourse::Helpers

    # `find` raises RecordNotFound, so an id that names nothing answers 404.
    before_action :find_resource, only: %i[show edit update destroy]

    # The model served here broadcasts refreshes for its index. On the way into every
    # action — before `create` commits, so its own change is broadcast — and again
    # after a dev reload hands the model a fresh class.
    before_action { resource_class.recourse_broadcast }

    # Lists one page of the model the route is named after. `@q` is Ransack's own
    # name for a search, which is what its form and sort link helpers look for.
    def index
      search = Recourse::Search.new resource_class, params[:q]
      @q = search.query
      @pagy, @resources = pagy search.scope.where(parent_columns)
    end

    # Builds a blank record under the name Rails would use: @contact for contacts.
    def new
      assign resource_class.new(parent_columns)
    end

    # Saves a submitted record, then shows the index again or redraws the form.
    def create
      record = assign resource_class.new(resource_params)
      model = human_name

      if record.save
        flash.notice = t 'recourse.created', model: model
        redirect_to url_for(action: :index), status: :see_other
      else
        flash.now.alert = t 'recourse.created_error', model: model
        render :new, status: :unprocessable_entity
      end
    end

    # Reads out the record the id names, which is already known to exist.
    def show; end

    # Shows the form for the record the id names, which is already known to exist.
    def edit; end

    # Saves changes to a record, then shows the index again or redraws the form.
    def update
      if @recourse.update resource_params
        flash.notice = t 'recourse.updated', model: human_name
        redirect_to url_for(action: :index), status: :see_other
      else
        flash.now.alert = t 'recourse.updated_error', model: human_name
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes the record and shows the index without it. `destroy!` rather than
    # `destroy`, so a callback that stops one says so instead of leaving the page
    # claiming it worked.
    def destroy
      @recourse.destroy!
      flash.notice = t 'recourse.deleted', model: human_name
      redirect_to url_for(action: :index), status: :see_other
    end
  end
end
