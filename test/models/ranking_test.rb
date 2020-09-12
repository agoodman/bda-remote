require 'test_helper'

class RankingTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:competition)
    should belong_to(:vessel)
  end

  context "validations" do
    should validate_presence_of(:competition_id)
    should validate_presence_of(:vessel_id)
    should validate_presence_of(:rank)
    should validate_presence_of(:score)
    should validate_presence_of(:kills)
    should validate_presence_of(:deaths)
    should validate_presence_of(:assists)
    should validate_presence_of(:hits_out)
    should validate_presence_of(:hits_in)
    should validate_presence_of(:dmg_out)
    should validate_presence_of(:dmg_in)
  end
end
