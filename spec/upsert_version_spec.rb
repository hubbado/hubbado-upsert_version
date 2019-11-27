require 'spec_helper'
require 'ffaker'

RSpec.describe UpsertVersion do
  context 'when dealing with a single target column' do
    subject { described_class.new(model_class) }

    let(:model_class) { Support::Model }
    let(:attributes) { {
      id: id,
      subject: new_subject,
      version: new_version
    }}
    let(:new_subject) { FFaker::Lorem.sentence }
    let(:id) { rand(100..10_000) }
    let(:new_version) { rand 3..8 }

    context 'when unique constraint is not conflicting on insert' do
      it "inserts the new record" do
        expect { subject.(attributes) }.to change { model_class.count }.by 1
      end

      it "sets the created_at and updated_at columns" do
        subject.(attributes)
        model = model_class.find(id)
        expect(model.created_at).to be_within(2.seconds).of(Time.current)
        expect(model.updated_at).to be_within(2.seconds).of(Time.current)
      end
    end

    context 'when insert conflicts with unique constraint' do
      let!(:model) { model_class.create!(id: id, version: model_version) }

      context 'and model is in lower version' do
        let(:model_version) { new_version - 1 }

        it 'does update the existing model' do
          expect { subject.(attributes); model.reload }
            .to change { model.subject }.to(new_subject)
            .and change { model.version }.from(model_version).to(new_version)
            .and change { model.updated_at }
        end
      end

      context 'but model is in the same version' do
        let(:model_version) { new_version }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.subject }
        end
      end

      context 'but model is in the higher version' do
        let(:model_version) { new_version + 1 }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.subject }
        end
      end
    end
  end

  context 'when dealing with dual target column' do
    subject { described_class.new(model_class, target: %i[user_id chat_id]) }

    let(:model_class) { Support::DualConstraintModel }
    let(:attributes) { {
      user_id: user_id,
      chat_id: chat_id,
      company_id: new_company_id,
      version: new_version
    }}
    let(:new_company_id) { SecureRandom.uuid }
    let(:user_id) { SecureRandom.uuid }
    let(:chat_id) { SecureRandom.uuid }
    let(:new_version) { rand 3..8 }

    context 'when unique constraint is not conflicting on insert' do
      before do
        model_class.create(
          user_id: user_id,
          chat_id: SecureRandom.uuid,
          company_id: SecureRandom.uuid,
          version: 0
        )
      end

      it "inserts the new record" do
        expect { subject.(attributes) }.to change { model_class.count }.by 1
      end
    end

    context 'when insert conflicts with unique constraint' do
      let!(:model) do
        model_class.create(
          user_id: user_id,
          chat_id: chat_id,
          company_id: SecureRandom.uuid,
          version: model_version
        )
      end

      context 'and model is in lower version' do
        let(:model_version) { new_version - 1 }

        it 'does update the existing model' do
          expect { subject.(attributes); model.reload }
            .to change { model.company_id }.to(new_company_id)
            .and change { model.version }.from(model_version).to(new_version)
        end
      end

      context 'but model is in the same version' do
        let(:model_version) { new_version }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.company_id }
        end
      end

      context 'but model is in the higher version' do
        let(:model_version) { new_version + 1 }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.company_id }
        end
      end
    end
  end
end
