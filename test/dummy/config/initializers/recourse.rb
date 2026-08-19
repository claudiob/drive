# A host app's one line about how every page looks. Pink rather than the default,
# so what a colour reaches — buttons, links, sorted headings, focus rings — is
# visible in a browser rather than only in a test.
Recourse.color = :pink

# And its one line about how a viewer keeps a row. A Proc rather than the relation
# itself: a relation built here would hold whoever was looking when the process
# booted, which in a real app is nobody. There is no session to read in a dummy, so
# the first person stands in for whoever is signed in.
Recourse.bookmarks = -> { Bookmark.where person: Person.order(:id).first }
