require 'test_helper'

class VesselTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:player)
    should belong_to(:competition)
    should have_many(:heat_assignments)
    should have_many(:heats)
  end

  context "validations" do
    should validate_presence_of(:player_id)
    should validate_presence_of(:competition_id)
  end
end
