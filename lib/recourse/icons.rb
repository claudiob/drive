# Reopened for the one thing a drawn resource cannot answer alone: which picture it
# is shown with, which its model names and Unicon translates.
module Recourse
  # What a resource is drawn with. The concept is the model's to name — `recourse_icon`
  # — and Unicon says what that concept is called in the set the pages draw from.
  def self.icon(name) = model_icon model(name)

  # The same for a model already in hand, which is what a counter cache counts: the
  # column names the class rather than the path some route drew it under.
  def self.model_icon(model) = Unicon[model.recourse_icon][:bootstrap]

  # `icon`, answering nil where Unicon has never heard the concept: a crumb or a
  # tab then draws no picture at all, since the fallback circle pictures nothing.
  def self.known_icon(name) = known_model_icon model(name)

  # And for a model in hand. A counter heading still takes the circle — an
  # icon-only heading has to show something — so `model_icon` keeps answering.
  def self.known_model_icon(model)
    concept = model.recourse_icon

    Unicon[concept][:bootstrap] if Unicon.names.include? concept
  end
end
