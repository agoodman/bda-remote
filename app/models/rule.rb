class Rule < ApplicationRecord
  belongs_to :competition

  validates_presence_of :strategy
  validates_presence_of :params

  @@strategy_map = {
      part_exists: "PartExists",
      float_property: "FloatModulePropertyCondition",
      int_property: "IntModulePropertyCondition",
      string_property: "StringModulePropertyCondition"
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
