require 'test_helper'

class RulesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get rules_new_url
    assert_response :success
  end

  test "should get index" do
    get rules_index_url
    assert_response :success
  end

  test "should get create" do
    get rules_create_url
    assert_response :success
  end

end
