# Reopened for the one thing a drawn resource cannot answer alone: which picture it
# is shown with, which its model names and Unicon translates.
module Recourse
  # What a resource is drawn with. The concept is the model's to name — `recourse_icon`
  # — and Unicon says what that concept is called in the set the pages draw from.
  def self.icon(name) = model_icon model(name)

  # The same for a model already in hand, which is what a counter cache counts: the
  # column names the class rather than the path some route drew it under.
  def self.model_icon(model) = Unicon[model.recourse_icon][:bootstrap]
end
