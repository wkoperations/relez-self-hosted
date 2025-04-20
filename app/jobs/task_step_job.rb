require "ostruct"

class TaskStepJob < ApplicationJob
  queue_as :default

  BATCH_INTERVAL = 0.25.seconds
  BATCH_SIZE = 10
  MAX_BUFFER_SIZE = 1_000_000 # 1MB

  # Map of task class names to their actual class objects
  # This eliminates the need for constantize, avoiding remote code execution risks
  TASK_CLASS_MAP = {
    "HelloWorldTask"        => HelloWorldTask
  }.freeze

  def perform(task_execution_id, step_index)
    # Make sure IO output is initialized to prevent uninitialized stream errors
    $stdout = STDOUT unless $stdout
    $stderr = STDERR unless $stderr

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

    # Broadcast the entire execution log update
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
      arguments: final_args
    )

    begin
      execute_local_step(task_execution, log, step, context)
    rescue => e
      log.mark_as_failed!
      task_execution.mark_as_failed!(e.message)

      # Broadcast failure update
      broadcast_execution_update(task_execution)

      raise
    end

    log.mark_as_success!

    # Broadcast success update
    broadcast_execution_update(task_execution)

    if step_index + 1 < task_class.steps_list.size
      TaskStepJob.perform_later(task_execution_id, step_index + 1)
    else
      task_execution.mark_as_success!

      # Broadcast final success update
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

  def execute_local_step(task_execution, log, step, context)
    output_io = StringIO.new
    original_stdout = $stdout
    custom_io = nil

    begin
      custom_io = create_custom_io(output_io, task_execution, log)
      $stdout = custom_io

      context.instance_exec(&step[:block])

      # Force flush any remaining output
      custom_io.flush
    rescue => e
      error_message = "ERROR: #{e.class.name}: #{e.message}\n"
      error_message += "BACKTRACE:\n#{e.backtrace.join("\n")}"
      puts error_message
      custom_io&.write(error_message)
      custom_io&.flush

      # Update the log explicitly
      log.with_lock do
        log.update!(output: log.output.to_s + error_message)
      end

      raise
    ensure
      $stdout = original_stdout
      custom_io&.close
    end
  end

  def create_custom_io(output_io, task_execution, log)
    @current_step_label = log.step_label
    @current_status = log.status

    Class.new(IO) do
      def initialize(output_io, task_execution, log, flush_output_proc)
        @output_io = output_io
        @task_execution = task_execution
        @log = log
        @flush_output = flush_output_proc
        @last_flush = Time.current
        @buffer = []
      end

      def write(string)
        # Only proceed if output_io is valid
        return 0 unless @output_io

        # Write to output_io and handle potential errors
        begin
          bytes_written = @output_io.write(string)
          @buffer << string
          # Use the updated time from flush_output
          new_time = @flush_output.call(@task_execution, @log, @buffer, @last_flush)
          @last_flush = new_time if new_time
          bytes_written
        rescue => e
          # Log the error but don't raise it to avoid breaking the task
          Rails.logger.error "Error writing to output: #{e.message}"
          0
        end
      end

      def flush
        # Only proceed if output_io is valid
        return unless @output_io

        begin
          @output_io.flush
          @flush_output.call(@task_execution, @log, @buffer, @last_flush, force: true)
        rescue => e
          Rails.logger.error "Error flushing output: #{e.message}"
        end
      end

      def close
        flush
        @output_io.close if @output_io && !@output_io.closed?
      end
    end.new(output_io, task_execution, log, method(:flush_output))
  end

  def flush_output(task_execution, log, buffer, last_flush, force: false)
    now = Time.current
    return unless force ||
                 buffer.size >= BATCH_SIZE ||
                 (now - last_flush) >= BATCH_INTERVAL ||
                 buffer.join.bytesize >= MAX_BUFFER_SIZE

    # Safeguard against nil buffer
    buffer ||= []
    output = buffer.join
    buffer.clear

    log.with_lock do
      current_output = log.output || "" # Ensure it's not nil
      log.update!(output: current_output + output)
    end

    # Use begin/rescue to handle potential broadcast errors
    begin
      Turbo::StreamsChannel.broadcast_append_to(
        "task_logs_#{task_execution.id}",
        target: "step-log-#{log.step_index}",
        content: output
      )
    rescue => e
      Rails.logger.error "Error broadcasting output: #{e.message}"
      # Still update the log, but don't break execution
    end

    # Return the current time to update last_flush
    now
  end

  def render_log_line(output)
    output
  end
end
