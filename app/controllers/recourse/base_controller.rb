module Recourse
  # Everything a recoursed screen does, in a class of its own so a host can put
  # its own behavior above it — `class RecoursesController < Recourse::BaseController`
  # with a `before_action :authenticate!` guards every screen the gem serves.
  class BaseController < ApplicationController
    include Pagy::Method, AttachmentResolution, ParentResolution, ReferenceResolution,
            ResourceResolution

    helper Helpers

    # `find` raises RecordNotFound, so an id that names nothing answers 404.
    before_action :find_resource, only: %i[show edit update destroy]

    # The model served here broadcasts refreshes for its index. On the way into every
    # action — before `create` commits, so its own change is broadcast — and again
    # after a dev reload hands the model a fresh class.
    before_action { resource_class.recourse_broadcast }

    # The model behind the page, assigned rather than worked out twice: a view asking
    # the name for itself would not know an attachment from a model of the app's own.
    before_action { @recourse_model = resource_class }

    # Lists one page of the model the route is named after. `@q` is Ransack's own
    # name for a search, which is what its form and sort link helpers look for.
    def index
      search = Search.new recourse_relation, params[:q]
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

  private

    # The rows the index lists, before the search, the sort and the page reach them.
    # Every row of the model by default, and the one thing a host overrides to put a
    # scope of its own behind a screen the gem otherwise draws whole:
    # `def recourse_relation = County.with_boosts_for(@recourse_parent)`. Private, so
    # that overriding it adds a query and never an action.
    def recourse_relation
      return attachment_relation if attachment_reflection

      resource_class.all
    end
  end
end
