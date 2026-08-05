# Superclass of the controllers the gem defines when a host app has none.
class RecoursesController < ApplicationController
  include Pagy::Method

  helper Recourse::Helpers

  # Lists one page of the model the route is named after.
  def index
    @pagy, @resources = pagy resource_class.all
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

private

  def assign(record)
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

    params.expect controller_name.singularize.to_sym => permitted
  end
end
