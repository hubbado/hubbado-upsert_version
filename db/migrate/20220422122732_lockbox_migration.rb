class LockboxMigration < ActiveRecord::Migration[7.0]
  def change
    remove_column :attr_encrypted_models, :encrypted_bank_account, :string
    remove_column :attr_encrypted_models, :encrypted_bank_account_iv, :string
    remove_column :attr_encrypted_models, :encrypted_bank_account_salt, :string
    remove_column :attr_encrypted_models, :encrypted_iban, :string
    remove_column :attr_encrypted_models, :encrypted_iban_iv, :string
    remove_column :attr_encrypted_models, :encrypted_iban_salt, :string

    add_column :attr_encrypted_models, :iban_ciphertext, :text
    add_column :attr_encrypted_models, :bank_account_ciphertext, :text
  end
end
