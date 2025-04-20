require "ostruct"

class TaskStepJob < ApplicationJob
  queue_as :default

  # Map of task class names to their actual class objects
  # This eliminates the need for constantize, avoiding remote code execution risks
  TASK_CLASS_MAP = {
    "HelloWorldTask" => HelloWorldTask
  }.freeze

  def perform(task_execution_id, step_index)
    task_execution = TaskExecution.find(task_execution_id)
    task_class_name = task_execution.task_class

    # Use direct class lookup from the map instead of constantize
    task_class = TASK_CLASS_MAP[task_class_name]

    # Validate the task class name against the map
    if task_class.nil?
      error_message = "Invalid or not implemented task class: #{task_class_name}"
      Rails.logger.error(error_message)
      task_execution.mark_as_failed!(error_message)
      raise SecurityError, error_message
    end
    step = task_class.steps_list[step_index]

    if step_index.zero?
      task_execution.mark_as_running!
    end

    log = task_execution.task_action_logs.find_by!(step_index: step_index)
    log.update!(status: "running", started_at: Time.current)

    # Broadcast the execution update
    broadcast_execution_update(task_execution)

    # Get default arguments from task class
    default_args = task_class.arguments_list || {}
    # Convert default args to string keys for consistency
    default_args = default_args.transform_keys(&:to_s)

    # Get user-specified arguments and convert to string keys
    user_args = (task_execution.arguments || {}).transform_keys(&:to_s)

    # Only keep user args that match default args
    user_args = user_args.slice(*default_args.keys)

    # Merge all arguments with proper precedence
    final_args = default_args.merge(user_args)

    context = StepContext.new(
      arguments: final_args,
      log: log,
      task_execution: task_execution
    )

    begin
      # Execute the step directly
      context.instance_exec(&step[:block])
      log.mark_as_success!
    rescue => e
      error_message = "ERROR: #{e.class.name}: #{e.message}\n"
      error_message += "BACKTRACE:\n#{e.backtrace.join("\n")}"
      log.update!(output: log.output.to_s + error_message)
      log.mark_as_failed!
      task_execution.mark_as_failed!(e.message)
      raise
    ensure
      # Broadcast final update
      broadcast_execution_update(task_execution)
    end

    if step_index + 1 < task_class.steps_list.size
      TaskStepJob.perform_later(task_execution_id, step_index + 1)
    else
      task_execution.mark_as_success!
      broadcast_execution_update(task_execution)
    end
  end

  private

  def broadcast_execution_update(task_execution)
    Turbo::StreamsChannel.broadcast_replace_to(
      "task_logs_#{task_execution.id}",
      target: "execution-details",
      content: ApplicationController.renderer.render(
        partial: "task_executions/execution_details",
        locals: { task_execution: task_execution }
      )
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "task_logs_#{task_execution.id}",
      target: "execution-log",
      content: ApplicationController.renderer.render(
        partial: "task_executions/execution_log",
        locals: { task_execution: task_execution }
      )
    )
  end
end
