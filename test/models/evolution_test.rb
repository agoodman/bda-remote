require 'test_helper'

class EvolutionTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should belong_to(:vessel)
    should have_many(:variant_groups)
    should have_many(:variants)
  end

  context "validations" do
    should validate_presence_of(:user_id)
    should validate_presence_of(:vessel_id)
    should validate_presence_of(:name)
    should validate_presence_of(:max_generations)
    should validate_numericality_of(:max_generations)
  end
end
