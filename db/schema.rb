# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_19_121930) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attr_encrypted_models", force: :cascade do |t|
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "iban_ciphertext"
    t.text "bank_account_ciphertext"
  end

  create_table "dual_constraint_models", force: :cascade do |t|
    t.string "chat_id"
    t.string "user_id"
    t.string "company_id"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id", "user_id"], name: "index_dual_constraint_models_on_chat_id_and_user_id", unique: true
  end

  create_table "models", force: :cascade do |t|
    t.string "subject"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "custom_version"
  end

end
