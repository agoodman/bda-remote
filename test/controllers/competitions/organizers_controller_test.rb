require 'test_helper'

class Competitions::OrganizersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get competitions_organizers_index_url
    assert_response :success
  end

  test "should post create" do
    post competitions_organizers_create_url
    assert_response :success
  end

  test "should delete destroy" do
    delete competitions_organizers_destroy_url
    assert_response :success
  end

end
