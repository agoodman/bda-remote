require 'test_helper'

class HeatTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:competition)
    should have_many(:heat_assignments)
    should have_many(:vessels)
  end

  context "validations" do
    should validate_presence_of(:competition_id)
  end
end
