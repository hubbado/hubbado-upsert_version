module Hubbado
  class UpsertVersion
    module Controls
      module Models
        module AttrEncryptedModel
          def self.model_class
            AttrEncryptedModel
          end

          def self.attributes(id: nil, bank_account: nil, version: nil)
            id ||= self.id
            bank_account ||= self.bank_account
            version ||= self.version

            {
              id: id,
              bank_account: bank_account,
              version: version
            }
          end

          def self.id
            ID.example
          end

          def self.bank_account
            '12345678'
          end

          def self.other_bank_account
            '34567890'
          end

          def self.iban
            "GB12345"
          end

          def self.version
            Version.example
          end

          class AttrEncryptedModel < ActiveRecord::Base
            has_encrypted :bank_account, :iban
          end
        end
      end
    end
  end
end
