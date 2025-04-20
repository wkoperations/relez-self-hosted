class CreateTaskExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :task_executions do |t|
      t.string :task_class, null: false
      t.json :arguments, default: {}
      t.string :status, default: "queued"
      t.datetime :started_at
      t.datetime :finished_at
      t.string :error_message

      t.timestamps
    end

    add_index :task_executions, :status
  end
end
