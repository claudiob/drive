module Recourse
  # Finds the record a nested route names, so `/counties/5/zips` lists county 5's
  # ZIPs, builds ZIPs inside it, and answers 404 when no county 5 exists.
  module ParentResolution
    extend ActiveSupport::Concern

    included do
      before_action :find_parent
    end

  private

    def find_parent
      @recourse_parent_association = parent_association
      return unless @recourse_parent_association

      @recourse_parent = @recourse_parent_association.klass.find parent_id
    end

    # What the route settled and every action honours: the index lists rows carrying
    # these columns, and `new` and `create` build records that do.
    def parent_columns
      return {} unless @recourse_parent

      { @recourse_parent_association.foreign_key => @recourse_parent.id }
    end

    # The belongs_to whose record the path names, or nil at the top level. Path
    # parameters rather than `params`, so a stray `?county_id=` nests nothing.
    def parent_association
      resource_class.recourse_references.find do |association|
        request.path_parameters.key? :"#{association.name}_id"
      end
    end

    def parent_id
      request.path_parameters[:"#{@recourse_parent_association.name}_id"]
    end
  end
end
