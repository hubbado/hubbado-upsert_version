class CreateDualConstraintModels < ActiveRecord::Migration[6.0]
  def change
    create_table :dual_constraint_models, force: true do |t|
      t.string :chat_id, unique: true
      t.string :user_id, unique: true
      t.string :company_id
      t.integer :version

      t.timestamps

      t.index %i[chat_id user_id], unique: true
    end
  end
end
