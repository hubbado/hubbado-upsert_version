require 'spec_helper'
require 'dependency'

RSpec.describe Hubbado::UpsertVersion::Substitute do
  let(:caller_class) do
    Class.new do
      include Dependency

      dependency :upsert_version, Hubbado::UpsertVersion
    end
  end

  it 'can be used as a substitute' do
    caller = caller_class.new
    attributes = { some_attribute: 'some value' }

    expect(caller.upsert_version.called?).to eq false

    caller.upsert_version.(attributes)

    expect(caller.upsert_version.called?).to eq true
    expect(caller.upsert_version.called_with?(attributes)).to eq true
  end

  it 'can set the result' do
    caller = caller_class.new
    result = Hubbado::UpsertVersion::Controls::Updated.example

    caller.upsert_version.set_result(result)

    expect(caller.upsert_version.(nil)).to eq result
  end
end
