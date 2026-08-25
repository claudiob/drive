require 'test_helper'
require 'integration_case'

# A resource reached through a key that names no one table. Nothing in the path says
# which key it is — `/zips/1/memos`, never `/abouts/1/memos` — so what settles it is
# the parent's own half of the association.
class TestRecoursesPolymorphic < IntegrationCase
  def teardown
    Memo.where(body: 'About a ZIP').destroy_all
    Memo.order(:id).group_by(&:person_id).each_value do |memos|
      memos.each_with_index { |memo, index| memo.update_column :position, index + 1 }
    end
  end

  # The rows a polymorphic key points at, and only those: the same page read under
  # the other ZIP is a different set, and the resource's own index is every memo
  # there is. The key itself stays off the table, the way an ordinary parent's does
  # -- the address answered it, so a column would only repeat the address.
  def test_a_nested_index_over_a_polymorphic_key_is_the_parents_own_rows
    zip, other = ZIP.order(:id).first 2
    visit "/zips/#{zip.id}/memos"

    assert_equal zip.memos.count, body.scan('data-cell="Body"').size
    refute_includes body, 'data-cell="About"'
    visit "/zips/#{other.id}/memos"

    assert_equal other.memos.count, body.scan('data-cell="Body"').size
    visit '/memos'

    assert_operator Memo.count, :>, zip.memos.count + other.memos.count
  end

  # The form asks for what the path has not already answered, and the write puts the
  # class name beside the id — a key carrying one without the other points into every
  # table at once.
  def test_a_nested_form_never_asks_which_parent_and_the_write_says_which
    zip = ZIP.order(:id).first
    visit "/zips/#{zip.id}/memos/new"

    refute_includes body, 'name="memo[about_id]"'
    assert_includes body, %(action="/zips/#{zip.id}/memos")
    @session.post "/zips/#{zip.id}/memos", params: { memo: { body: 'About a ZIP' } }

    assert_equal 303, @session.response.status
    assert_equal zip, Memo.find_by!(body: 'About a ZIP').about
  end

  # And a route the parent declares no half for is left exactly as it was: a page
  # gathered from several parents at once is nobody's one record, and the host's
  # `recourse_relation` is still what scopes it. Teams keep no memos, so the key
  # the model does carry is not quietly read as this nesting.
  def test_a_parent_that_declares_no_half_resolves_no_parent
    team = Team.order(:id).second
    visit "/teams/#{team.id}/memos"

    # Still a column, where the ZIP's own page has none: nothing here took the key
    # for the parent the address names, so nothing hid it as already answered.
    assert_includes body, 'data-cell="About"'
    assert_empty Memo.where(about: team)
    refute_empty body.scan('data-cell="Body"')
  end

  # And so are the rows a drag counts among. The route that arranges is drawn a
  # segment below the listing, where no nesting is recorded — so a page correct to
  # read could still renumber every other parent's rows on a drop.
  def test_a_move_under_a_polymorphic_key_leaves_the_other_parents_alone
    zip = ZIP.order(:id).first
    elsewhere = Memo.where.not(about: zip).order(:id).pluck :id, :position
    moved = zip.memos.order(:position).last

    @session.patch "/zips/#{zip.id}/memos/#{moved.id}/position", params: { position: 1 }

    assert_includes [204, 303], @session.response.status
    assert_equal 1, moved.reload.position
    assert_equal elsewhere, Memo.where.not(about: zip).order(:id).pluck(:id, :position)
  end
end
