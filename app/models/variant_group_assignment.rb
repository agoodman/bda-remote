class VariantGroupAssignment < ApplicationRecord
  belongs_to :variant_group
  belongs_to :competition

  validates :competition_id, presence: true
  validates :variant_group_id, presence: true
end
