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
    # these columns, and `new` and `create` build records that do. A listing that
    # edits a join is the exception, and lists every row of the far side: the parent
    # is what the buttons write, not what the rows have in common.
    def parent_columns
      return {} if resource_join || !@recourse_parent

      { @recourse_parent_association.foreign_key => @recourse_parent.id }
    end

    # The belongs_to whose record the path names, or nil at the top level. Path
    # parameters rather than `params`, so a stray `?county_id=` nests nothing. A
    # join's own keys count too: the far side of a many-to-many holds none pointing
    # at the parent, which is what the join row is for.
    def parent_association
      associations = resource_class.recourse_references + join_references

      associations.find { |association| request.path_parameters.key? :"#{association.name}_id" }
    end

    def join_references
      resource_join ? resource_join.recourse_references : []
    end

    def resource_join
      Recourse.join_of controller_path
    end

    def parent_id
      request.path_parameters[:"#{@recourse_parent_association.name}_id"]
    end
  end
end
