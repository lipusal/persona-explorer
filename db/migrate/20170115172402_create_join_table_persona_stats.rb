class CreateJoinTablePersonaStats < ActiveRecord::Migration[5.0]
  def change
    create_join_table(:personas, :stats, table_name: 'persona_stats') do |t|
      t.integer :value

      t.timestamps
    end
  end
end
