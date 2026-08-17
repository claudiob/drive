module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    # Draws what `resources` draws, after supplying any controller the host lacks. A
    # block nests what it declares under each resource — ZIPs at
    # `/counties/:county_id/zips` — with the nested controller namespaced after the
    # parent, so it and the top-level `ZIPsController` stay two controllers. Only a
    # `recourses` block adds that namespace, which every nested page relies on, so
    # nesting inside a plain `resources` block raises here rather than serving a
    # broken page. A `namespace` may sit in between — what is refused is a nesting
    # that adds no namespace at all. A nested resource defaults to
    # `only: %i[index new create]`, and an explicit `only:` or `except:` is the
    # host's word, which wins.
    def recourses(*names, **options, &block)
      refuse_unscoped_nesting names

      names.each do |name|
        # The module is the namespace being drawn in, so a resource is declared
        # and its controller defined under the path Rails will route to.
        path = [current_module, name].compact.join '/'
        record_declaration path
        Controllers.define_missing path
      end

      return resources(*names, **default_nested_actions(options)) unless block

      resources(*names, **default_nested_actions(options)) do
        scope module: parent_resource.name, &block
      end
    end

    # What `resource` draws, recorded the same way: one record reached without an id,
    # at `/providers/5/authentication`. Rails routes a singular resource to a plural
    # controller, so that is the path declared here — and recording it is the whole
    # point, since an action drawn with no index of its own earns its button on the
    # parent, and only a recorded nesting is ever looked for there.
    def recourse(*names, **)
      refuse_unscoped_nesting names

      names.each do |name|
        path = [current_module, name.to_s.pluralize].compact.join '/'
        record_declaration path
        Controllers.define_missing path
      end

      resource(*names, **)
    end

  private

    # The Mapper keeps its scope in an internal frame with no reader, so the two
    # facts this DSL needs — the module being drawn in, and the resource a block
    # nests under — are read in these two methods and nowhere else: a Rails
    # upgrade that moves the frame edits one file, twice.
    def current_module
      @scope[:module]
    end

    def parent_resource
      @scope[:scope_level_resource]
    end

    def record_declaration(path)
      # A nested resource is reached through its parent rather than the sidebar,
      # so it is recorded under the parent's path — that order is its tabs' order.
      return Recourse.declare path unless parent_resource

      Recourse.nest parent_path, path
    end

    # The parent's own controller path: the module being drawn in, cut off after the
    # parent resource's own segment, so a `namespace` between the two is left out
    # rather than mistaken for the parent itself.
    def parent_path
      parts = current_module.to_s.split '/'

      parts[0..parts.rindex(parent_resource.name)].join '/'
    end

    # Reached through a parent, a nested resource answers its collection actions —
    # list the parent's rows, add one — unless the host names its own. The member
    # actions belong to a resource's own top-level routes.
    def default_nested_actions(options)
      return options if !parent_resource || options.key?(:only) || options.key?(:except)

      options.merge only: %i[index new create]
    end

    def refuse_unscoped_nesting(names)
      parent = parent_resource
      return if parent.nil? || current_module.to_s.split('/').include?(parent.name)

      raise Error, I18n.t('recourse.nested', names: names.map(&:inspect).join(', '),
                                             parent: parent.name)
    end
  end
end
