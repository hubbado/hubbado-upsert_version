module Hubbado
  class UpsertVersion
    module Controls
      module Inserted
        def self.example(attributes = nil)
          attributes ||= Attributes.example

          Hubbado::UpsertVersion::Inserted.new(attributes)
        end
      end
    end
  end
end
