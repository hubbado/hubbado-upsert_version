module Hubbado
  class UpsertVersion
    module Controls
      # There are no constraints imposed by this gem on what can be used as a
      # target column. ID could be a UUID, but the controls in this gem use
      # integers.
      module ID
        def self.example
          11
        end
      end
    end
  end
end
