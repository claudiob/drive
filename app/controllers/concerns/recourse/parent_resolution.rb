module Recourse
  # Finds the record a nested route names, so `/counties/5/zips` lists county 5's
  # ZIPs, builds ZIPs inside it, and answers 404 when no county 5 exists.
  module ParentResolution
    extend ActiveSupport::Concern

    included do
      before_action :find_parent
    end

  private

    # An attachment's parent is the other one the routes can name and no key points
    # at: a blob holds nothing pointing back, the way the far side of a join does not.
    def find_parent
      @recourse_parent_association = parent_association
      @recourse_parent = if @recourse_parent_association
                           @recourse_parent_association.klass.find parent_id
                         else
                           attachment_parent
                         end
    end

    # What the route settled and every action honours: the index lists rows carrying
    # these columns, and `new` and `create` build records that do. A listing that
    # edits a join is the exception, and lists every row of the far side: the parent
    # is what the buttons write, not what the rows have in common.
    def parent_columns
      return {} if resource_join || attachment_reflection || @recourse_parent_association.nil?

      { @recourse_parent_association.foreign_key => @recourse_parent.id }
    end

    # The belongs_to whose record the path names, or nil at the top level. Path
    # parameters rather than `params`, so a stray `?county_id=` nests nothing. A
    # join's own keys count too: the far side of a many-to-many holds none pointing
    # at the parent, which is what the join row is for.
    def parent_association
      associations = own_references + join_references

      associations.find { |association| request.path_parameters.key? :"#{association.name}_id" }
    end

    # A host may serve a page over something that is no Active Record model at all --
    # an aggregate it assembles itself -- and such a class answers no questions about
    # keys. The routes still named a parent, and the host still finds it.
    def own_references
      resource_class.respond_to?(:recourse_references) ? resource_class.recourse_references : []
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

    # Whether this page is the level a position is counted at, which turns on the
    # parent above and so is answered here rather than in the controller. A model of
    # a host's own that answers no questions about keys is not one either.
    def arranged?
      return false unless resource_class.respond_to? :recourse_order

      Recourse.arranges? resource_class, @recourse_parent_association
    end
  end
end
