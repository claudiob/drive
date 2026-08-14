# A list of media URLs, held as JSON in a text column so any database can store
# it, and read back as the Array the pages loop over. The coder is also what
# keeps it an Array: an empty list is stored as NULL and loaded as [].
module Mediable
  extend ActiveSupport::Concern

  included do
    serialize :media_urls, coder: JSON, type: Array
  end
end
