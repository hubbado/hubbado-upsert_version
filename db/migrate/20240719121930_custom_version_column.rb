class CustomVersionColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :models, :custom_version, :integer
  end
end
