module Recourse
  module Helpers
    # What a table of attachments draws that a table of records does not: the one
    # column naming a file is the way to open it.
    module Attachments
    private

      # True for the filename of a blob, and for nothing else — a host model with a
      # column of that name is drawing its own value, not Active Storage's.
      def blob_filename?(column)
        column == 'filename' && blob_resource?
      end

      # By name, so an app with no Active Storage never mentions the constant.
      def blob_resource?
        resource_model.name == 'ActiveStorage::Blob'
      end

      # The file itself, in a tab of its own: an admin opening one is leaving the
      # page they were reading, and a download that replaced it would lose their place.
      def blob_link(blob, filename)
        link_to filename, main_app.rails_blob_path(blob, disposition: :attachment),
                target: '_blank', rel: 'noopener'
      end
    end
  end
end
