class CreateAttrEncryptedModels < ActiveRecord::Migration[6.0]
  def change
    create_table :attr_encrypted_models, force: true do |t|
      t.string :encrypted_bank_account
      t.string :encrypted_bank_account_iv
      t.string :encrypted_bank_account_salt
      t.string :encrypted_iban
      t.string :encrypted_iban_iv
      t.string :encrypted_iban_salt
      t.integer :version

      t.timestamps
    end
  end
end
