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

ActiveRecord::Schema[8.0].define(version: 2025_04_20_204030) do
  create_table "app_configs", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value_type"
    t.index ["key"], name: "index_app_configs_on_key"
  end

  create_table "task_action_logs", force: :cascade do |t|
    t.integer "task_execution_id", null: false
    t.integer "step_index", null: false
    t.string "step_label", null: false
    t.string "status"
    t.text "output"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_execution_id", "step_index"], name: "index_task_action_logs_on_task_execution_id_and_step_index"
    t.index ["task_execution_id"], name: "index_task_action_logs_on_task_execution_id"
  end

  create_table "task_executions", force: :cascade do |t|
    t.string "task_class", null: false
    t.json "arguments", default: {}
    t.string "status", default: "queued"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.index ["status"], name: "index_task_executions_on_status"
  end

  add_foreign_key "task_action_logs", "task_executions"
end
