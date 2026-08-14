module Recourse
  module Helpers
    # What a nested page knows about the record above it.
    module Parents
      # The record a nested route names above this page, or nil at the top level.
      def resource_parent
        controller.view_assigns['recourse_parent']
      end

      # The belongs_to that record is reached through, which names the foreign key
      # every row on the page shares.
      def resource_parent_association
        controller.view_assigns['recourse_parent_association']
      end

    private

      # The crumbs a nested page sits under: the parent's own index, then the record
      # the path names — `Counties`, then `Alameda County`, before `ZIPs`. The
      # record's crumb links to its show page, where one is routed to link to.
      def parent_breadcrumbs
        parent = resource_parent
        return [] unless parent

        path = controller.controller_path.rpartition('/').first
        [
          [path, path.split('/').last.humanize, url_for(controller: "/#{path}", action: :index)],
          [nil, parent.attributes[parent.class.recourse_label.to_s], parent_path(parent, path)],
        ]
      end

      def parent_path(parent, path)
        return unless routed? path, 'show'

        url_for controller: "/#{path}", action: :show, id: parent
      end
    end
  end
end
