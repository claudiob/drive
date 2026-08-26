module Recourse
  # Everything a recoursed screen does, in a class of its own so a host can put
  # its own behavior above it — `class RecoursesController < Recourse::BaseController`
  # with a `before_action :authenticate!` guards every screen the gem serves.
  class BaseController < ApplicationController
    include Pagy::Method, AttachmentResolution, AttachmentWriting, Paging,
            ListResolution, ParentResolution, PolymorphicParents, ReferenceResolution,
            ResourceResolution, Zoning

    helper Helpers

    # `find` raises RecordNotFound, so an id that names nothing answers 404.
    before_action :find_resource, only: %i[show edit update destroy]

    # The model behind the page, assigned once, and only where the route names one.
    before_action { @recourse_model = resource_class if resource_model? }

    # The model broadcasts refreshes for its index, before `create` commits its own.
    before_action :broadcast_resource_changes

    # Lists one page of the model the route is named after. `@q` is Ransack's own name.
    def index
      search = Search.new recourse_relation, params[:q], arranged: arranged?
      @q = search.query
      @pagy, @resources = pagy search.scope, limit: recourse_limit
    end

    # Builds a blank record under the name Rails would use: @contact for contacts.
    def new
      assign resource_class.new(parent_columns)
    end

    # Saves a submitted record, then shows the index again or redraws the form.
    def create
      record = assign resource_class.new(resource_params)
      model = human_name

      if create_resource record
        wrote t('recourse.created', model: model), record
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
      if update_resource @recourse
        wrote t('recourse.updated', model: human_name), @recourse
      else
        flash.now.alert = t 'recourse.updated_error', model: human_name
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes the record and shows the index without it. `destroy!`, so a callback that
    # stops one says so rather than leaving the page claiming it worked.
    def destroy
      @recourse.destroy!
      wrote t('recourse.deleted', model: human_name)
    end

  private

    # What a write says once it has landed: the message, and the row it landed on where
    # one survives, for the page to mark while that message stands.
    def wrote(message, record = nil)
      flash.notice = message
      flash[Recourse::WRITTEN] = Recourse.row_id record if record
      redirect_to written_url, status: :see_other
    end

    # Where a write goes once it has landed: the index, or the record's own page where
    # the routes drew none — a singular resource is the collection of one.
    def written_url
      url_for action: Recourse.routed?(controller_path, 'index') ? :index : :show
    end

    def broadcast_resource_changes
      @recourse_model.recourse_broadcast if @recourse_model.respond_to? :recourse_broadcast
    end

    # The rows the index lists, before the search, the sort and the page reach them:
    # every row of the model, narrowed by the parent a nested route names. The one thing
    # a host overrides to put a scope of its own behind a screen the gem draws whole —
    # `def recourse_relation = County.with_boosts_for(@recourse_parent)`. Private, so
    # overriding it adds a query and never an action.
    def recourse_relation
      return attachment_relation if attachment_reflection

      resource_class.where parent_columns
    end
  end
end
