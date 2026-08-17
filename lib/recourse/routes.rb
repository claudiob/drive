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
      through = options.delete :through

      names.each { |name| declare_resource name, through }

      return resources(*names, **default_nested_actions(options)) unless block || through

      resources(*names, **default_nested_actions(options)) do
        scope module: parent_resource.name do
          draw_join through if through
          instance_exec(&block) if block
        end
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

    # The module is the namespace being drawn in, so a resource is declared and its
    # controller defined under the path Rails will route to.
    def declare_resource(name, through)
      path = [current_module, name].compact.join '/'
      record_declaration path
      Recourse.join path, through if through
      Controllers.define_missing path
    end

    # The row a listing's Add and Remove write: one record joining the parent to the
    # row the button sat on, reached at `/people/1/teams/2/membership` and answered
    # by a controller of the gem's own rather than by the generic one.
    def draw_join(through)
      path = [current_module, through].compact.join '/'
      # Recorded under the listing it belongs to, which is how it finds its way back
      # there for a request that arrived without a referer. No tab and no button
      # come of it: both ask for an index, and a join has none.
      Recourse.nest current_module, path
      Controllers.define_missing path, JoinsController
      resource through.to_s.singularize.to_sym, only: %i[create destroy]
    end

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
