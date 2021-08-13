class CreateModels < ActiveRecord::Migration[6.0]
  def change
    create_table :models, force: true do |t|
      t.string :subject
      t.integer :version

      t.timestamps
    end
  end
end
