class Rule < ApplicationRecord
  belongs_to :competition

  validates_presence_of :strategy
  validates_presence_of :params
end
