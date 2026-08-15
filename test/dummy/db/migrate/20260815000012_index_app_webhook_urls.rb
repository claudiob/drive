# An indexed string is what the search box looks through, so indexing the one
# column App hides is what proves `recourse_hidden` keeps it out of the search.
class IndexAppWebhookURLs < ActiveRecord::Migration[8.1]
  def change
    add_index :apps, :webhook_url
  end
end
