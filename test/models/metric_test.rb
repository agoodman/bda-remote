require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:competition)
  end

  context "validations" do
    should validate_presence_of(:competition_id)
    should validate_presence_of(:kills)
    should validate_presence_of(:deaths)
    should validate_presence_of(:assists)
    should validate_presence_of(:hits_out)
    should validate_presence_of(:hits_in)
    should validate_presence_of(:dmg_out)
    should validate_presence_of(:dmg_in)
    should validate_numericality_of(:kills)
    should validate_numericality_of(:deaths)
    should validate_numericality_of(:assists)
    should validate_numericality_of(:hits_out)
    should validate_numericality_of(:hits_in)
    should validate_numericality_of(:dmg_out)
    should validate_numericality_of(:dmg_in)
  end
end
