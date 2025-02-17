module Hubbado
  class UpsertVersion
    module Controls
      module Updated
        def self.example(attributes = nil)
          attributes ||= Attributes.example

          Hubbado::UpsertVersion::Updated.new(attributes)
        end
      end
    end
  end
end
