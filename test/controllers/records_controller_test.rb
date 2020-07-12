require 'test_helper'

class RecordsControllerTest < ActionDispatch::IntegrationTest
  test "on POST batch" do
    assert_difference("Record.count", 1) do
      post competition_heat_records_batch_url(1, 1), params: { records: [ { vessel_id: 1, hits: 1, kills: 1, deaths: 1 } ] }
    end
    assert_response :success
  end
end
