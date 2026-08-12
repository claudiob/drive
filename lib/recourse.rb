require 'pagy'
# Before searchable.rb, so its `extend` lands ahead of Ransack's own defaults.
require 'ransack'
require 'unicon'

require_relative 'recourse/version'
require_relative 'recourse/colors'
require_relative 'recourse/icons'
require_relative 'recourse/controllers'
require_relative 'recourse/helpers'
require_relative 'recourse/recoursive'
require_relative 'recourse/search'
require_relative 'recourse/searchable'
require_relative 'recourse/engine'

# Namespace for the gem: the routes.rb DSL and the screens it mounts.
module Recourse
  class << self
    # Resources `recourses` has drawn, in the order config/routes.rb lists them.
    attr_reader :declared
  end

  @declared = []

  # Records a resource as declared, keeping order and ignoring a repeated draw.
  def self.declare(name)
    @declared << name.to_s unless @declared.include? name.to_s
  end

  # Columns a user may set: the form offers these, the show page reads these out, and
  # `create` permits these. A counter cache is none of a user's business — Rails keeps
  # it, so a form that offered one would let it be typed over.
  def self.editable_columns(model)
    model.column_names - %w[id created_at updated_at] - model.recourse_counters.keys
  end

  # Lower case, but for the words Rails was told are acronyms: `ZIP code` reads as
  # `ZIP code` and never `zip code`, while `Code or Name` becomes `code or name`.
  def self.downcase(text)
    acronyms = ActiveSupport::Inflector.inflections.acronyms

    text.split.map { |word| acronyms.key?(word.downcase) ? word : word.downcase }.join ' '
  end

  # The model a resource is named after. A controller the gem defined has nothing
  # else to go on, so a name that resolves to no model is a routes file to fix
  # rather than a `NameError` from somewhere inside a view.
  def self.model(name)
    # A namespaced resource is `admin/sources`, and the model it lists is a Source.
    model = name.to_s.split('/').last.classify

    model.safe_constantize || raise(Error, I18n.t('recourse.missing_model', name:, model:))
  end

  # Raised for every failure the gem reports, so hosts can rescue one type.
  class Error < StandardError; end
end
