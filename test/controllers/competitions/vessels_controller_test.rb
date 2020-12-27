require 'test_helper'

class Competitions::VesselsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get competitions_vessels_index_url
    assert_response :success
  end

  test "should get new" do
    get competitions_vessels_new_url
    assert_response :success
  end

end
