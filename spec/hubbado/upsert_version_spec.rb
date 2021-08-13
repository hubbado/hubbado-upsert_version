require 'spec_helper'
require 'ffaker'

RSpec.describe Hubbado::UpsertVersion do
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

  context 'when dealing with encrypted attributes' do
    subject { described_class.new(model_class) }

    let(:model_class) { Support::AttrEncryptedModel }
    let(:attributes) { {
      id: id,
      bank_account: new_bank_account,
      version: new_version
    }}
    let(:new_bank_account) { '0987654321' }
    let(:id) { rand(100..10_000) }
    let(:new_version) { rand 3..8 }

    context 'when unique constraint is not conflicting on insert' do
      it "inserts the new record" do
        expect { subject.(attributes) }.to change { model_class.count }.by 1
      end

      it "sets the encrypted columns" do
        subject.(attributes)
        model = model_class.find(id)

        expect(model.bank_account).to eq new_bank_account
        expect(model.encrypted_bank_account).not_to be nil
        expect(model.encrypted_bank_account_salt).not_to be nil
        expect(model.encrypted_bank_account_iv).not_to be nil
      end

      it "doesn't set other encrypted columns" do
        subject.(attributes)
        model = model_class.find(id)

        expect(model.iban).to be nil
        expect(model.encrypted_iban).to be nil
        expect(model.encrypted_iban_salt).to be nil
        expect(model.encrypted_iban_iv).to be nil
      end

      it "sets the created_at and updated_at columns" do
        subject.(attributes)
        model = model_class.find(id)
        expect(model.created_at).to be_within(2.seconds).of(Time.current)
        expect(model.updated_at).to be_within(2.seconds).of(Time.current)
      end
    end

    context 'when insert conflicts with unique constraint' do
      let(:model_version) { new_version - 1 }

      let!(:model) do
        model_class.create!(
          id: id,
          bank_account: "12345",
          iban: "GB12345",
          version: model_version
        )
      end

      context 'and model is in lower version' do
        it 'does update the existing model' do
          expect { subject.(attributes); model.reload }
            .to change { model.bank_account }.to(new_bank_account)
            .and change { model.version }.from(model_version).to(new_version)
            .and change { model.updated_at }
        end

        it 'does not update unprovided encrypted attributes' do
          expect { subject.(attributes); model.reload }
            .not_to change { model.iban }
        end

        context 'and no encrypted attribute is updated' do
          let(:attributes) do
            {
              id: id,
              version: new_version
            }
          end

          it 'does update the existing model' do
            expect { subject.(attributes); model.reload }
              .to change { model.version }.from(model_version).to(new_version)
              .and change { model.updated_at }
          end
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
