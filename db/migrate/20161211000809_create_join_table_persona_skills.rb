class CreateJoinTablePersonaSkills < ActiveRecord::Migration[5.0]
  def change
    create_join_table(:personas, :skills, table_name: 'persona_skills') do |t|
      t.string :cost
      t.integer :level

      # t.index [:persona_id, :skill_id]
      # t.index [:skill_id, :persona_id]
    end
  end
end
