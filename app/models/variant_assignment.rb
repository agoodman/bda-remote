class VariantAssignment < ApplicationRecord
  belongs_to :variant
  belongs_to :vessel

  validates :variant_id, presence: true
  validates :vessel_id, presence: true
end
