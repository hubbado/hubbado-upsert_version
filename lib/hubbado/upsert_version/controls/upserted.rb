module Hubbado
  class UpsertVersion
    module Controls
      module Upserted
        def self.example(attributes = nil)
          attributes ||= Attributes.example

          Hubbado::UpsertVersion::Upserted.new(attributes)
        end
      end
    end
  end
end