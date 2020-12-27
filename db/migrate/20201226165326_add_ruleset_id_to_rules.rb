class AddRulesetIdToRules < ActiveRecord::Migration[6.0]
  def change
    add_column :rules, :ruleset_id, :integer
    add_column :competitions, :ruleset_id, :integer
    Competition.find_each do |c|
      rs = Ruleset.create(name: "#{c.name} rules")
      Rule.where(competition_id: c.id).update_all(ruleset_id: rs.id)
      c.ruleset_id = rs.id
      c.save!
    end
    remove_column :rules, :competition_id
  end
end
