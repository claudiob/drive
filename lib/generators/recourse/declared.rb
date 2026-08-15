module Recourse
  module Generators
    # The models behind the routes a host has drawn, for a generator that writes
    # something for each of them. Private for the reason `Seeds` is.
    module Declared
    private

      def declared_models
        # Generators run before a lazy route set is drawn, and drawing is the only
        # thing that tells `recourses` apart from the rest of the routes file.
        # Unconditionally: the guarded variant Rails keeps for itself is unpublished,
        # and a second load costs nothing in a one-shot generator process.
        Rails.application.reload_routes!

        Recourse.declared.filter_map { |path| declared_model path }.uniq
      end

      # A declared resource with no model — drawn for a controller of the host's
      # own — is reported and passed over rather than failing the whole run.
      def declared_model(path)
        Recourse.model path
      rescue Recourse::Error => e
        say_status :skip, e.message
        nil
      end
    end
  end
end
