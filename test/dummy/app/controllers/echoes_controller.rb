# A controller the host app owns, to prove the gem does not replace one it finds.
class EchoesController < ActionController::Base
  # Renders a marker no gem-supplied controller would produce.
  def index
    render plain: 'the host app answered'
  end
end
