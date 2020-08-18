require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should have_many(:vessels)
  end

  context "validations" do
    should validate_presence_of(:user_id)
    should validate_presence_of(:name)
  end
end
