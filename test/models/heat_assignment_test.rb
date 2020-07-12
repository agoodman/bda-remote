require 'test_helper'

class HeatAssignmentTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:heat)
    should belong_to(:vessel)
  end

  context "validations" do
    should validate_presence_of(:heat_id)
    should validate_presence_of(:vessel_id)
  end
end
