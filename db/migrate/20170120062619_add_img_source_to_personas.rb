class AddImgSourceToPersonas < ActiveRecord::Migration[5.0]
  def change
    add_column :personas, :img, :string
  end
end
