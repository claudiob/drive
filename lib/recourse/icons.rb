# Reopened for the one question a drawn resource cannot answer alone: which icon
# set is being served, and what this resource is called in it.
module Recourse
  # The icon sets a resource can be asked to name itself in.
  ICON_SYSTEMS = %i[android bootstrap ios].freeze

  # What a resource is drawn with, in one set's naming. The answer comes from the model
  # rather than from a list here: `recourse_icon` returns a symbol when every set calls
  # the icon the same thing, and a hash keyed by set when they do not.
  def self.icon(name, system)
    icon = model(name)&.recourse_icon || Recoursive::ICON

    icon.is_a?(Hash) ? icon.fetch(system, Recoursive::ICON) : icon
  end

  # A resource names a model by convention, but not always — `recourses :echoes` draws
  # a controller the host wrote and no model at all, and that one takes the default.
  def self.model(name)
    name.to_s.classify.safe_constantize
  end
end
