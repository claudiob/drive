# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ApplicationController
  include Pagy::Method

  helper Recourse::Helpers

  # `find` raises RecordNotFound, so an id that names nothing answers 404.
  before_action :find_resource, only: %i[edit update]

  # Lists one page of the model the route is named after. `@q` is Ransack's own
  # name for a search, which is what its form and sort link helpers look for.
  def index
    search = Recourse::Search.new resource_class, params[:q]
    @q = search.query
    @pagy, @resources = pagy search.scope
  end

  # Builds a blank record under the name Rails would use: @contact for contacts.
  def new
    assign resource_class.new
  end

  # Saves a submitted record, then shows the index again or redraws the form.
  def create
    record = assign resource_class.new(resource_params)

    if record.save
      flash.notice = "#{human_name} was created."
      redirect_to url_for(action: :index), status: :see_other
    else
      flash.now.alert = "#{human_name} could not be created."
      render :new, status: :unprocessable_entity
    end
  end

  # Shows the form for the record the id names, which is already known to exist.
  def edit; end

  # Saves changes to a record, then shows the index again or redraws the form.
  def update
    if @recourse.update resource_params
      flash.notice = "#{human_name} was updated."
      redirect_to url_for(action: :index), status: :see_other
    else
      flash.now.alert = "#{human_name} could not be updated."
      render :edit, status: :unprocessable_entity
    end
  end

private

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

  # A foreign key whose label is typed arrives as that label, so it is looked up
  # here. Nothing found leaves the key nil, and `belongs_to` reports it missing.
  def resolve_references(attributes)
    resource_class.reflect_on_all_associations(:belongs_to).each do |association|
      key = association.foreign_key.to_s
      next unless attributes.key?(key) && association.klass.recourse_typed_reference?

      attributes[key] = reference_id association, attributes[key]
    end

    attributes
  end

  def reference_id(association, label)
    association.klass.find_by(association.klass.recourse_label => label)&.id
  end
end
