require 'test_helper'

class CompetitionTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:user)
    should have_many(:records)
    should have_many(:heats)
    should have_many(:vessels)
    should have_many(:rules)
    should have_many(:rankings)
    should have_one(:metric)
  end

  context "validations" do
    should validate_presence_of(:user_id)
    should validate_presence_of(:name)
    should validate_presence_of(:stage)
    should validate_presence_of(:status)
  end

  test "newly created competition should assign zero stage" do
    competition = Competition.new
    assert_not competition.nil?, "nil competition"
    assert_not competition.stage.nil?, "nil stage"
    assert_equal competition.stage, 0, "stage invalid"
  end
end
