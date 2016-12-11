class CreateJoinTablePersonaElement < ActiveRecord::Migration[5.0]
  def change
    create_join_table(:personas, :elements, table_name: 'persona_elements') do |t|
      t.string :effect

      # t.index [:persona_id, :element_id]
      # t.index [:element_id, :persona_id]
    end
  end
end
