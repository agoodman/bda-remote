require 'test_helper'

class Heats::VesselsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get heats_vessels_index_url
    assert_response :success
  end

end
