require 'test_helper'

class Competitions::PlayersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get competitions_players_index_url
    assert_response :success
  end

end
