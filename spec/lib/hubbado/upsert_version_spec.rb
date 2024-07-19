require 'spec_helper'

RSpec.describe Hubbado::UpsertVersion do
  describe '.build' do
    let(:model_class) { Hubbado::UpsertVersion::Controls::Models::Model }

    it 'can build an instance' do
      instance = described_class.build(model_class, target: :id)

      expect(instance.klass).to be model_class
      expect(instance.target).to eq [:id]
      expect(instance.version_column_name).to be :version
    end

    context 'when passing version_column_name' do
      it 'sets that value' do
        instance = described_class.build(model_class, target: :id, version_column_name: :custom_version)

        expect(instance.version_column_name).to be :custom_version
      end
    end
  end

  context 'when dealing with a single target column' do
    subject { described_class.new(model_class) }

    let(:model_class) { Hubbado::UpsertVersion::Controls::Models::Model.model_class }
    let(:attributes) { {
      "id" => id,
      "subject" => new_subject,
      "version" => new_version
    }}
    let(:new_subject) { Hubbado::UpsertVersion::Controls::Models::Model.subject }
    let(:id) { Hubbado::UpsertVersion::Controls::Models::Model.id }
    let(:new_version) { Hubbado::UpsertVersion::Controls::Models::Model.version }

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

      it "returns a result with the upserted values" do
        result = subject.(attributes)

        expect(result.upserted?).to eq(true)
        expect(result.attributes).to include(
          **attributes
        )
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

        it "returns a result with the upserted values" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(true)
          expect(result.attributes).to include(
            **attributes
          )
        end
      end

      context 'but model is in the same version' do
        let(:model_version) { new_version }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.subject }
        end

        it "does not return upserted result" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(false)
        end
      end

      context 'but model is in the higher version' do
        let(:model_version) { new_version + 1 }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.subject }
        end

        it "does not return upserted result" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(false)
        end
      end
    end
  end

  context 'when dealing with encrypted attributes' do
    subject { described_class.new(model_class) }

    let(:model_class) { Hubbado::UpsertVersion::Controls::Models::AttrEncryptedModel.model_class }
    let(:attributes) do
      Hubbado::UpsertVersion::Controls::Models::AttrEncryptedModel.attributes(
        id: id, bank_account: bank_account, version: version
      )
    end
    let(:id) { Hubbado::UpsertVersion::Controls::Models::AttrEncryptedModel.id }
    let(:bank_account) { Hubbado::UpsertVersion::Controls::Models::AttrEncryptedModel.bank_account }
    let(:version) { 2 }

    context 'when unique constraint is not conflicting on insert' do
      it "inserts the new record" do
        expect { subject.(attributes) }.to change { model_class.count }.by 1
      end

      it "sets the encrypted columns" do
        subject.(attributes)
        model = model_class.find(id)

        expect(model.bank_account).to eq bank_account
        expect(model.bank_account_ciphertext).not_to be nil
      end

      it "doesn't set other encrypted columns" do
        subject.(attributes)
        model = model_class.find(id)

        expect(model.iban).to be nil
        expect(model.iban_ciphertext).to be nil
      end

      it "sets the created_at and updated_at columns" do
        subject.(attributes)
        model = model_class.find(id)
        expect(model.created_at).to be_within(2.seconds).of(Time.current)
        expect(model.updated_at).to be_within(2.seconds).of(Time.current)
      end
    end

    context 'when insert conflicts with unique constraint' do
      let(:model_version) { version - 1 }

      let!(:model) do
        model_class.create!(
          id: id,
          bank_account: Hubbado::UpsertVersion::Controls::Models::AttrEncryptedModel.other_bank_account,
          iban: Hubbado::UpsertVersion::Controls::Models::AttrEncryptedModel.iban,
          version: model_version
        )
      end

      context 'and model is in lower version' do
        it 'does update the existing model' do
          expect { subject.(attributes); model.reload }
            .to change { model.bank_account }.to(bank_account)
            .and change { model.version }.from(model_version).to(version)
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
              version: version
            }
          end

          it 'does update the existing model' do
            expect { subject.(attributes); model.reload }
              .to change { model.version }.from(model_version).to(version)
              .and change { model.updated_at }
          end
        end
      end
    end
  end

  context 'when dealing with dual target column' do
    subject { described_class.new(model_class, target: %i[user_id chat_id]) }

    let(:model_class) { Hubbado::UpsertVersion::Controls::Models::DualConstraintModel }
    let(:attributes) { {
      "user_id" => user_id,
      "chat_id" => chat_id,
      "company_id" => new_company_id,
      "version" => new_version
    }}
    # TODO: Replace with Controls
    let(:new_company_id) { SecureRandom.uuid }
    let(:user_id) { SecureRandom.uuid }
    let(:chat_id) { SecureRandom.uuid }
    let(:new_version) { 2 }

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

      it "returns a result with the upserted values" do
        result = subject.(attributes)

        expect(result.upserted?).to eq(true)
        expect(result.attributes).to include(
          **attributes
        )
      end
    end

    context 'when insert conflicts with unique constraint' do
      let!(:model) do
        model_class.create(
          user_id: user_id,
          chat_id: chat_id,
          company_id: SecureRandom.uuid, # TODO: Replace with Control
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

        it "returns a result with the upserted values" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(true)
          expect(result.attributes).to include(
            **attributes
          )
        end
      end

      context 'but model is in the same version' do
        let(:model_version) { new_version }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.company_id }
        end

        it "does not return upserted result" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(false)
        end
      end

      context 'but model is in the higher version' do
        let(:model_version) { new_version + 1 }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.company_id }
        end

        it "does not return upserted result" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(false)
        end
      end
    end
  end

  context 'when dealing with another version column' do
    subject { described_class.new(model_class, version_column_name: :custom_version) }

    let(:model_class) { Hubbado::UpsertVersion::Controls::Models::Model.model_class }
    let(:attributes) { {
      "id" => id,
      "subject" => new_subject,
      "custom_version" => new_version
    }}
    let(:new_subject) { Hubbado::UpsertVersion::Controls::Models::Model.subject }
    let(:id) { Hubbado::UpsertVersion::Controls::Models::Model.id }
    let(:new_version) { Hubbado::UpsertVersion::Controls::Models::Model.version }

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

      it "returns a result with the upserted values" do
        result = subject.(attributes)

        expect(result.upserted?).to eq(true)
        expect(result.attributes).to include(
          **attributes
        )
      end
    end

    context 'when insert conflicts with unique constraint' do
      let!(:model) { model_class.create!(id: id, custom_version: model_version) }

      context 'and model is in lower version' do
        let(:model_version) { new_version - 1 }

        it 'does update the existing model' do
          expect { subject.(attributes); model.reload }
            .to change { model.subject }.to(new_subject)
            .and change { model.custom_version }.from(model_version).to(new_version)
            .and change { model.updated_at }
        end

        it "returns a result with the upserted values" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(true)
          expect(result.attributes).to include(
            **attributes
          )
        end
      end

      context 'but model is in the same version' do
        let(:model_version) { new_version }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.subject }
        end

        it "does not return upserted result" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(false)
        end
      end

      context 'but model is in the higher version' do
        let(:model_version) { new_version + 1 }

        it 'does not update the existing model' do
          expect { subject.(attributes); model.reload }.not_to change { model.subject }
        end

        it "does not return upserted result" do
          result = subject.(attributes)

          expect(result.upserted?).to eq(false)
        end
      end
    end
  end

  context 'when having more than one version column' do
    context 'and has already been inserted from one version column' do
      let(:model_class) { Hubbado::UpsertVersion::Controls::Models::Model.model_class }
      let(:id) { Hubbado::UpsertVersion::Controls::Models::Model.id }
      let(:subject) { Hubbado::UpsertVersion::Controls::Models::Model.subject }
      let(:version) { Hubbado::UpsertVersion::Controls::Models::Model.version }

      it 'updates the record using another version column' do
        default_version_column = described_class.new(model_class)
        attributes = {
          "id" => id,
          "subject" => subject,
          "version" => version
        }

        expect { default_version_column.(attributes) }.to change { model_class.count }.by 1

        custom_version_column = described_class.new(
          model_class, version_column_name: :custom_version
        )
        attributes = {
          "id" => id,
          "subject" => "Another subject",
          "custom_version" => version
        }

        expect { custom_version_column.(attributes) }.to_not change { model_class.count }

        model = model_class.find(id)
        expect(model.subject).to eq("Another subject")
      end
    end
  end
end
