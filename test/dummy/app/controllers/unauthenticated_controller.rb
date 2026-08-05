# Base class for controllers a signed-out visitor is allowed to reach.
class UnauthenticatedController < ApplicationController
  # Not the gem's layout: it draws a breadcrumb and a sidebar for a recourse, and
  # this controller is not one, so the breadcrumb's link to its index would raise.
  layout 'unauthenticated'
end
