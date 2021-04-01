require 'test_helper'

class VariantTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:variant_group)
  end

  context "validations" do
    should validate_presence_of(:variant_group_id)
    should validate_presence_of(:values)
  end
end
