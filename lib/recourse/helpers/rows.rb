module Recourse
  module Helpers
    # The row partial a table renders: the host's for this resource where one is
    # defined — every column its own — and the gem's generic row otherwise.
    module Rows
      # What the cache key reads so the table notices its row partial. Rails
      # resolves `render 'row'` per request, but no template digest follows it
      # there — the digestor reads the gem's own views — so a host `_row` added or
      # edited after a fragment was written would keep serving the row it replaced.
      def row_digest
        row = lookup_context.find 'row', lookup_context.prefixes, true

        Digest::MD5.hexdigest row.source
      end
    end
  end
end
