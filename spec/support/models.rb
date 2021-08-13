module Support
  class Model < ActiveRecord::Base; end

  class DualConstraintModel < ActiveRecord::Base; end

  class AttrEncryptedModel < ActiveRecord::Base
    attr_encrypted_options.merge!(
      key: SecureRandom.random_bytes(32),
      mode: :per_attribute_iv_and_salt
    )
    attr_encrypted :bank_account
    attr_encrypted :iban
  end
end
