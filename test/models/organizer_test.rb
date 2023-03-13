require 'test_helper'

class OrganizerTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should belong_to(:competition)
  end

  context "validations" do
    should validate_presence_of(:user_id)
    should validate_presence_of(:competition_id)
  end
end
