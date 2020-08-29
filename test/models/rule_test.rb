require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:competition)
  end

  context "validations" do
    should validate_presence_of(:strategy)
    should validate_presence_of(:params)
  end
end
