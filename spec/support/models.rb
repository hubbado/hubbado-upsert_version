module Support
  class Model < ActiveRecord::Base; end

  class DualConstraintModel < ActiveRecord::Base; end

  class AttrEncryptedModel < ActiveRecord::Base
    LOCKBOX_TEST_KEY = '0000000000000000000000000000000000000000000000000000000000000000'.freeze

    lockbox_encrypts :bank_account, :iban
  end
end
