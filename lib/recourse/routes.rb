module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    # Draws what `resources` draws, after supplying any controller the host lacks. A
    # block nests what it declares under each resource — ZIPs at
    # `/counties/:county_id/zips` — with the nested controller namespaced after the
    # parent, so it and the top-level `ZIPsController` stay two controllers. Only a
    # `recourses` block adds that namespace, which every nested page relies on, so
    # nesting inside a plain `resources` block raises here rather than serving a
    # broken page. A nested resource defaults to `only: %i[index new create]`,
    # and an explicit `only:` or `except:` is the host's word, which wins.
    def recourses(*names, **options, &block)
      refuse_unscoped_nesting names

      names.each do |name|
        # `@scope[:module]` is the namespace being drawn in, so a resource is declared
        # and its controller defined under the path Rails will route to.
        path = [@scope[:module], name].compact.join '/'
        # A nested resource is reached through a row of its parent's index, so the
        # sidebar gets no entry for it.
        Recourse.declare path unless @scope[:scope_level_resource]
        Controllers.define_missing path
      end

      return resources(*names, **default_nested_actions(options)) unless block

      resources(*names, **default_nested_actions(options)) do
        scope module: @scope[:scope_level_resource].name, &block
      end
    end

  private

    # Reached through a parent, a nested resource answers its collection actions —
    # list the parent's rows, add one — unless the host names its own. The member
    # actions belong to a resource's own top-level routes.
    def default_nested_actions(options)
      nested = @scope[:scope_level_resource]
      return options if !nested || options.key?(:only) || options.key?(:except)

      options.merge only: %i[index new create]
    end

    def refuse_unscoped_nesting(names)
      parent = @scope[:scope_level_resource]
      return if parent.nil? || @scope[:module].to_s.split('/').last == parent.name

      raise Error, I18n.t('recourse.nested', names: names.map(&:inspect).join(', '),
                                             parent: parent.name)
    end
  end
end
