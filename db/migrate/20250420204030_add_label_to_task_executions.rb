class AddLabelToTaskExecutions < ActiveRecord::Migration[8.0]
  def change
    add_column :task_executions, :label, :string
  end
end
