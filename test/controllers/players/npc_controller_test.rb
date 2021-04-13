require 'test_helper'

class Players::NpcControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get players_npc_new_url
    assert_response :success
  end

end
