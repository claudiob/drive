# Reopened for the order a row reads in, which a table, a show page and a form all ask
# for the same way.
module Recourse
  # Which part of a row a column belongs to. What a column holds is the gem's to know
  # and where the schema put it is the host's, so both have a say: the kind picks the
  # band, and the order inside the band is the one the table already has. Extended onto
  # `Recourse`, so this is `Recourse.ordered` wherever it is called from.
  module Columns
    # The bands, in the order a row reads. Counts open it, beside the action columns
    # that follow them into the record; then what kind of row this is and what state it
    # is in, its flags, whose it is, what it says, the long values a narrow column suits
    # least, when it happened, and the two Rails keeps.
    BANDS = %i[counter state boolean reference scalar long date timestamp].freeze

    # Values that are paragraphs rather than words, under every name an adapter has for
    # them: PostgreSQL reports `jsonb` where SQLite and MySQL report `json`.
    LONG_KINDS = %i[text json jsonb].freeze

    # And the ones that are a point in time, whichever part of one they keep.
    DATE_KINDS = %i[date datetime time].freeze

    # The columns of a model in the order a row reads them, given whichever of them the
    # caller is drawing. Grouped rather than sorted: `group_by` keeps the order it was
    # given inside each group, which is what leaves an order the schema already carries
    # standing, and `sort_by` would not — Ruby's sort is not stable.
    def ordered(model, names)
      keys = reference_keys model

      names.group_by { |name| BANDS.index band(model, name, keys) }.sort.flat_map(&:last)
    end

  private

    # Asked in the order that settles it. A counter is one whatever it is stored as; the
    # column Rails keeps a subclass in says what kind of row this is, as an enum says
    # what state it is in; and a key is an integer, so it has to be recognised as a key
    # before its type is asked about at all.
    def band(model, name, keys)
      return :counter if model.recourse_counters.key? name
      return :state if name == model.inheritance_column || model.defined_enums.key?(name)
      return :timestamp if TIMESTAMPS.include? name
      return :reference if keys.include? name

      band_of model.type_for_attribute(name).type
    end

    def band_of(kind)
      return :boolean if kind == :boolean
      return :long if LONG_KINDS.include? kind
      return :date if DATE_KINDS.include? kind

      :scalar
    end

    def reference_keys(model)
      model.recourse_references.map { |reference| reference.foreign_key.to_s }
    end
  end

  extend Columns
end
