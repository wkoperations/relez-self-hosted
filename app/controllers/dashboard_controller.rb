class DashboardController < ApplicationController
  def index
    @recent_task_executions = TaskExecution.order(created_at: :desc).limit(3)
  end
end
