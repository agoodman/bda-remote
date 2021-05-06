class Rule < ApplicationRecord
  belongs_to :ruleset

  validates :ruleset_id, presence: true
  validates :strategy, presence: true
  validates :params, presence: true

  @@strategy_map = {
      part_count: "PartCount",
      part_exists: "PartExists",
      part_not_exists: "PartNotExists",
      part_set_contains: "PartSetContains",
      part_set_count: "PartSetCount",
      float_module_property: "FloatModulePropertyCondition",
      int_module_property: "IntModulePropertyCondition",
      string_module_property: "StringModulePropertyCondition",
      resource_property: "ResourcePropertyCondition",
      ship_size: "ShipSizeCondition",
      ship_type: "ShipTypeCondition",
      ship_cost: "ShipCostCondition",
      ship_mass: "ShipMassCondition",
      ship_points: "ShipPointsCondition"
  }
  def self.strategy_keys
    @@strategy_map.keys
  end
  def self.strategies
    @@strategy_map
  end
  def self.strategy_select_options
    @@strategy_map.map { |k,v| [v, k] }.to_h
  end
end
