class CreateTaskActionLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :task_action_logs do |t|
      t.references :task_execution, null: false, foreign_key: true
      t.integer :step_index, null: false
      t.string :step_label, null: false
      t.string :status
      t.text :output
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :task_action_logs, [ :task_execution_id, :step_index ]
  end
end
