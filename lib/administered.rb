# Namespace for the controllers the gem serves. It is a top-level module rather
# than Recourse::Administered because the routes name it as the controller
# module, and defining it here means a route to a controller that does not exist
# yet fails on the controller's full name instead of on the namespace.
module Administered
end
