require 'test_helper'

class EvolutionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get evolutions_index_url
    assert_response :success
  end

  test "should get new" do
    get evolutions_new_url
    assert_response :success
  end

end
