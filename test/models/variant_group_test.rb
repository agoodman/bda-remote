require 'test_helper'

class VariantGroupTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:evolution)
    should have_many(:variants)
  end

  context "validations" do
    should validate_presence_of(:evolution_id)
    should validate_presence_of(:keys)
  end
end
