module Recourse
  module Helpers
    # The tabs on the card a record's pages share: a look, a change, and each
    # nested index under the record — counted where the record keeps a count.
    module Cards
    private

      # The pages of the record the card is about, as `[label, path, current]` — a
      # look first, a change second, then one tab per nested index: `8 ZIPs` where
      # a counter cache answers, the bare `Settings` where none does. On a nested
      # index the card is the parent record's, so the tabs are too, and the nested
      # tab is the current one.
      def resource_tabs(record)
        path = card_path
        actions = %i[show edit].filter_map { |action| action_tab record, path, action }

        actions + nested_tabs(record, path) + host_tabs(record)
      end

      # Tabs no route can name: a page filed under another resource, and one a record
      # only sometimes has. A host answers `recourse_extra_tabs` in a helper of its
      # own with `[label, path]` pairs — asked for rather than required, so an app
      # with no such page writes nothing. Which of them is current is the gem's to
      # say, the way it is for every other tab.
      def host_tabs(record)
        return [] unless respond_to? :recourse_extra_tabs

        recourse_extra_tabs(record).map { |label, path| [label, path, current_page?(path)] }
      end

      # The resource the card belongs to: the parent's, on a page nested under it —
      # read off the routes rather than chopped off this page's own path, which a
      # `namespace` between the two would leave pointing at the namespace.
      def card_path
        return Recourse.parent_of controller.controller_path if resource_parent

        controller.controller_path
      end

      def action_tab(record, path, action)
        return unless routed? path, action.to_s

        [
          tab_label(action), url_for(controller: "/#{path}", action:, id: record),
          current_action_tab?(action),
        ]
      end

      # `update` redraws the form it rejected, so the edit tab is current there too.
      # On a nested page neither is: the count tab is the page being read.
      def current_action_tab?(action)
        return false if resource_parent

        action == (controller.action_name == 'show' ? :show : :edit)
      end

      # One tab per index nested under the record, in the order routes.rb nested
      # them — the order the sidebar already keeps. The nested route is the whole
      # requirement: a `has_many` of that name decides how the tab reads, and a
      # counter cache whether it carries a number, but neither is what puts it there.
      def nested_tabs(record, path)
        Recourse.nested_under(path).filter_map do |nested|
          # Whatever the routes drew between the parent and the resource — a
          # `namespace`, usually nothing — and then the resource's own name.
          namespace = nested.delete_prefix("#{path}/").split '/'
          name = namespace.pop
          next unless routed? nested, 'index'

          [nested_tab_label(record, name, namespace),
           nested_index_url(record, path, nested), nested == controller.controller_path,]
        end
      end

      def tab_label(action)
        safe_join [icon_tag(Actions::ICONS[action]), t("recourse.#{action}")], ' '
      end
    end
  end
end
