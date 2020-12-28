class AddSummaryToRulesets < ActiveRecord::Migration[6.0]
  def change
    add_column :rulesets, :summary, :text
  end
end
