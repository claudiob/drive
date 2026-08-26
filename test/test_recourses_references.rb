require 'test_helper'
require 'integration_case'

# A foreign key whose label is typed rather than picked, and what becomes of the words
# somebody typed into it.
class TestRecoursesReferences < IntegrationCase
  def teardown
    Reading.where(depth: 4_242).destroy_all
  end

  # The ordinary case: the words name one row, and the key points at it.
  def test_a_label_naming_one_row_is_the_row_it_names
    sensor = Sensor.find_by! name: 'Weir'

    @session.post '/readings', params: { reading: { depth: 4_242, sensor_id: 'Weir' } }

    assert_equal 303, @session.response.status
    assert_equal sensor, Reading.find_by!(depth: 4_242).sensor
  end

  # And the one this is about. Two sensors answer to `North gate`, so the words name a
  # sensor without saying which — and the first of the two is not an answer, only the
  # one the database happened to return. Nothing is written, and the field says why.
  def test_a_label_naming_two_rows_is_refused_rather_than_guessed_at
    named = Sensor.where(name: 'North gate').count

    @session.post '/readings',
                  params: { reading: { depth: 4_242, sensor_id: 'North gate' } }

    assert_operator named, :>, 1
    assert_equal 422, @session.response.status
    assert_nil Reading.find_by(depth: 4_242)
    assert_includes body, 'Matches more than one record, so it does not say which'
    assert_includes body, 'North gate'
  end

  # A label naming nothing is the case that already worked: the key is left empty, and
  # what becomes of the record is the association's own business — this one is optional,
  # so it is written without a sensor rather than refused.
  def test_a_label_naming_nothing_leaves_the_key_empty
    @session.post '/readings',
                  params: { reading: { depth: 4_242, sensor_id: 'Nowhere at all' } }

    assert_equal 303, @session.response.status
    assert_nil Reading.find_by!(depth: 4_242).sensor
  end
end
