class Rule < ApplicationRecord
  belongs_to :competition

  validates_presence_of :strategy
  validates_presence_of :params

  @@strategy_map = {
      part_exists: "PartExists",
      part_not_exists: "PartNotExists",
      part_set_contains: "PartSetContains",
      float_module_property: "FloatModulePropertyCondition",
      int_module_property: "IntModulePropertyCondition",
      string_module_property: "StringModulePropertyCondition",
      resource_property: "ResourcePropertyCondition",
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
