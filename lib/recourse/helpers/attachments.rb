module Recourse
  module Helpers
    # What a table of attachments draws that a table of records does not: the one
    # column naming a file is the way to open it — and the field a form offers for
    # putting one there.
    module Attachments
    private

      # The attachments this screen's model keeps, which the form draws after every
      # column it has: a file input is the widest control on the page.
      def attachment_names
        Recourse.attachment_names resource_model
      end

      # One labelled file input, in the grid a column's field sits in. `multiple` where
      # the model keeps several, and no hidden blank beside it: nothing here is ever
      # assigned, so a field nobody touched is one the write passes over.
      def attachment_field(name)
        label = resource_model.human_attribute_name name

        tag.div class: ROW do
          safe_join [
            @recourse_form.label(name, label, class: 'form-label'),
            @recourse_form.file_field(name, class: 'form-control', **attachment_options(name)),
          ]
        end
      end

      def attachment_options(name)
        return {} unless Recourse.attachment_many? resource_model, name

        { multiple: true, include_hidden: false }
      end

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
