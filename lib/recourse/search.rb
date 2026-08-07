module Recourse
  # The Ransack search behind an index: what a heading asked to sort by, what the
  # search box asked to match, and the relation those add up to.
  class Search
    # Predicates whose value is a list, which is how a multiple combobox submits:
    # one input holding every chosen value, comma-joined.
    LIST_PREDICATES = /_(not_)?in\z/

    # The Ransack object the form and the sort links read.
    attr_reader :query

    # A search of `model` for the `q` parameters the request carried.
    def initialize(model, params)
      @model = model
      @query = model.ransack conditions(params)
    end

    # The relation the index lists. Ransack has already ordered it where a heading
    # asked, so the model's own order only applies when nothing did.
    def scope
      scope = @query.result
      scope = scope.order @model.recourse_order if @query.sorts.empty?
      includes = @model.recourse_includes
      return scope if includes.blank?

      scope.includes includes
    end

  private

    # Ransack reads nothing it has not been shown — `ransackable_attributes` is the
    # allowlist — so what arrives here needs no permitting, only untangling: a list
    # predicate is split back into values, and a filter nobody set is dropped,
    # since `IN ()` would match no row rather than every one.
    def conditions(params)
      # `?q=anything` reaches here as a String rather than as parameters of its own,
      # and a search nobody asked for reaches here as nil. Neither is a condition.
      return {} unless params.respond_to? :to_unsafe_h

      params.to_unsafe_h.filter_map do |key, value|
        next if value.blank?

        [key, key.match?(LIST_PREDICATES) ? value.to_s.split(',') : value]
      end.to_h
    end
  end
end
