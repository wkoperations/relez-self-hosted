class TaskExecutionsController < ApplicationController
  before_action :set_task_execution, only: [ :show ]

  def show
  end

  private

  def set_task_execution
    @task_execution = TaskExecution.find(params[:id])
  end
end
