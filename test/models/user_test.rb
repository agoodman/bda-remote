require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "associations" do
    should have_many(:competitions)
    should have_many(:evolutions)
    should have_one(:player)
  end
end
