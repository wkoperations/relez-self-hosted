class TaskActionLog < ApplicationRecord
  belongs_to :task_execution, touch: true

  validates :step_index, presence: true
  validates :step_label, presence: true
  validates :status, inclusion: { in: %w[queued running success failed] }, allow_nil: true

  def mark_as_success!
    update!(status: "success", finished_at: Time.current)
  end

  def mark_as_failed!
    update!(status: "failed", finished_at: Time.current)
  end
end
