require 'test_helper'

class VesselTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:player)
    should have_many(:heat_assignments)
    should have_many(:heats)
    should have_many(:rankings)
  end

  context "validations" do
    should validate_presence_of(:player_id)
    should validate_presence_of(:name)
    should validate_presence_of(:craft_url)
  end
end
