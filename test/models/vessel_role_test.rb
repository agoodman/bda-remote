require 'test_helper'

class VesselRoleTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:competition)
  end

  context "validations" do
    should validate_presence_of(:competition_id)
    should validate_presence_of(:name)
  end
end
