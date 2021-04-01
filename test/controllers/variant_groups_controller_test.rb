require 'test_helper'

class VariantGroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get variant_groups_show_url
    assert_response :success
  end

end
