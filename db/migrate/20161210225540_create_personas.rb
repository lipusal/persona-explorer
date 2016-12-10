class CreatePersonas < ActiveRecord::Migration[5.0]
  def change
    create_table :personas do |t|
      t.string :name
      t.integer :arcana_id
      t.integer :level
      t.string :source

      t.timestamps
    end

    add_foreign_key :personas, :arcanas
  end
end
