class BaseTask
  class << self
    def argument(name, default: nil)
      arguments_list[name] = default
    end

    def step(label, remote: false, &block)
      steps_list << { label: label, remote: remote, block: block }
    end

    def steps_list
      @steps_list ||= []
    end

    def arguments_list
      @arguments_list ||= {}
    end
  end

  def initialize(arguments: {})
    @arguments = self.class.arguments_list.merge(arguments)
  end

  def run
    self.class.steps_list.each_with_index do |step, index|
      execute_step(step, index)
    end
  end

  def log(message)
    return unless @current_log

    # Append the message with a timestamp
    formatted_message = "[#{Time.current.strftime('%H:%M:%S')}] #{message}\n"

    # Update the log in the database
    @current_log.with_lock do
      current_output = @current_log.output || ""
      @current_log.update!(output: current_output + formatted_message)
    end

    # Broadcast the new log line
    begin
      Turbo::StreamsChannel.broadcast_append_to(
        "task_logs_#{@current_task_execution.id}",
        target: "step-log-#{@current_log.step_index}",
        content: formatted_message
      )
    rescue => e
      Rails.logger.error "Error broadcasting log: #{e.message}"
    end
  end

  private

  def execute_step(step, index)
    context = StepContext.new(
      arguments: @arguments
    )

    if step[:remote]
      execute_remote_step(step, index, context)
    else
      execute_local_step(step, index, context)
    end
  end

  def execute_remote_step(step, index, context)
    command = context.instance_exec(&step[:block])
    # Remote execution logic will be implemented in TaskStepJob
  end

  def execute_local_step(step, index, context)
    # Local execution logic will be implemented in TaskStepJob
  end
end

class StepContext
  def initialize(arguments:, log: nil, task_execution: nil)
    @arguments = arguments.transform_keys(&:to_sym)
    @log = log
    @task_execution = task_execution
  end

  def log(message)
    return unless @log

    # Append the message with a timestamp
    formatted_message = "[#{Time.current.strftime('%H:%M:%S')}] #{message}\n"

    # Update the log in the database
    @log.with_lock do
      current_output = @log.output || ""
      @log.update!(output: current_output + formatted_message)
    end

    # Broadcast the new log line
    begin
      Turbo::StreamsChannel.broadcast_append_to(
        "task_logs_#{@task_execution.id}",
        target: "step-log-#{@log.step_index}",
        content: formatted_message
      )
    rescue => e
      Rails.logger.error "Error broadcasting log: #{e.message}"
    end
  end

  def method_missing(name, *args)
    Rails.logger.info "StepContext method_missing called with: #{name}"
    Rails.logger.info "Available arguments: #{@arguments.inspect}"

    # Prevent method injection
    return super if name.to_s.start_with?("__")

    if @arguments.key?(name)
      @arguments[name]
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    # Prevent method injection
    return super if name.to_s.start_with?("__")

    @arguments.key?(name) || super
  end

  # Make this public explicitly
  public

  # Return the list of methods, excluding argument keys
  def public_methods(include_super = true)
    super(include_super) - @arguments.keys.map(&:to_s)
  end

  # Move private to after the method we want to keep public
  private

  # Prevent other method injection through public methods
end
