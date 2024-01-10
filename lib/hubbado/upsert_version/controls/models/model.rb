module Hubbado
  class UpsertVersion
    module Controls
      module Models
        module Model
          def self.model_class
            Model
          end

          def self.subject
            "Example subject"
          end

          def self.id
            ID.example
          end

          def self.version
            Version.example
          end

          class Model < ActiveRecord::Base; end
        end
      end
    end
  end
end
