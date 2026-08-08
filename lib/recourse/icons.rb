# Reopened for the one thing a drawn resource cannot answer alone: which picture it
# is shown with, which its model names and Unicon translates.
module Recourse
  # What a resource is drawn with. The concept is the model's to name — `recourse_icon`
  # — and Unicon says what that concept is called in the set the pages draw from.
  def self.icon(name)
    Unicon[model(name).recourse_icon][:bootstrap]
  end
end
