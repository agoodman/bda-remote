class Variant < ApplicationRecord
  include Craft
  require "open-uri"

  belongs_to :variant_group
  has_one :variant_assignment
  has_one :vessel, through: :variant_assignment

  validates :variant_group_id, presence: true
  validates :values, presence: true

  after_create :build_vessel

  def build_vessel
    return unless variant_assignment.nil?
    # construct vessel by downloading craft and modifying it according to the keys defined
    # in the variant group and their associated values defined in this variant.

    craft = URI::open(variant_group.evolution.latest_vessel.craft_url).read
    new_craft = modify_craft(craft, variant_group.keys.split(","), values.split(","))
    new_name = "#{variant_group.evolution.vessel.name}-G#{variant_group.generation}-V#{id}"
    new_vessel = upload_craft(new_craft, new_name, variant_group.evolution.user.player.id)
    VariantAssignment.create(variant_id: id, vessel_id: new_vessel.id)
  end
end
