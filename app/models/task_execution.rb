class TaskExecution < ApplicationRecord
  has_many :task_action_logs, dependent: :destroy

  validates :task_class, presence: true
  validates :status, inclusion: { in: %w[queued running success failed] }
  validates :label, presence: true

  attribute :status, :string, default: "queued"

  after_create_commit :broadcast_recent_events
  after_update_commit :broadcast_recent_events

  def running?
    status == "running"
  end

  def completed?
    %w[success failed].include?(status)
  end

  def mark_as_running!
    update!(status: "running", started_at: Time.current)
  end

  def mark_as_success!
    update!(status: "success", finished_at: Time.current)
  end

  def mark_as_failed!(error_message)
    update!(status: "failed", finished_at: Time.current, error_message: error_message)
  end

  private

  def broadcast_recent_events
    broadcast_replace_to "recent_events",
      target: "recent_events",
      partial: "dashboard/recent_events",
      locals: { recent_task_executions: TaskExecution.order(created_at: :desc).limit(3) }
  end
end
