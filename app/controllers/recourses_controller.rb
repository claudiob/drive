# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ApplicationController
  include Pagy::Method, Recourse::Data, Recourse::Parameters

  helper Recourse::Helpers

  # `find` raises RecordNotFound, so an id that names nothing answers 404.
  before_action :find_resource, only: %i[edit update]

  # Lists one page of the model the route is named after, as a page or as data.
  def index
    @pagy, @resources = pagy resource_scope

    respond_to do |format|
      format.html
      format.json { render json: index_json }
    end
  end

  # Builds a blank record under the name Rails would use: @contact for contacts.
  def new
    assign resource_class.new
  end

  # Saves a submitted record, then shows the index again or redraws the form.
  def create
    record = assign resource_class.new(resource_params)

    return refused record, :new, 'created' unless record.save

    accepted record, 'created', :created
  end

  # Shows the form for the record the id names, which is already known to exist.
  def edit; end

  # Saves changes to a record, then shows the index again or redraws the form.
  def update
    return refused @recourse, :edit, 'updated' unless @recourse.update resource_params

    accepted @recourse, 'updated', :ok
  end

private

  def accepted(record, verb, status)
    flash.notice = "#{human_name} was #{verb}."

    respond_to do |format|
      format.html { redirect_to url_for(action: :index), status: :see_other }
      format.json { render_saved record, status }
    end
  end

  def refused(record, form, verb)
    flash.now.alert = "#{human_name} could not be #{verb}."

    respond_to do |format|
      format.html { render form, status: :unprocessable_entity }
      format.json { render_rejected record }
    end
  end

  # Every table cell that names a referenced record would otherwise be a query.
  def resource_scope
    names = resource_class.reflect_on_all_associations(:belongs_to).map(&:name)
    return resource_class.all if names.empty?

    resource_class.includes(*names)
  end

  def find_resource
    assign resource_class.find(params.expect(:id))
  end

  def assign(record)
    @recourse = record
    instance_variable_set "@#{controller_name.singularize}", record
  end

  def resource_class
    controller_name.classify.constantize
  end

  def human_name
    resource_class.model_name.human
  end

  def resource_params
    permitted = Recourse.editable_columns resource_class

    resolve_references params.expect(controller_name.singularize.to_sym => permitted)
  end
end
