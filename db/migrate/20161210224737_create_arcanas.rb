class CreateArcanas < ActiveRecord::Migration[5.0]
  def change
    create_table :arcanas do |t|
      t.text :name

      t.timestamps
    end
  end
end
