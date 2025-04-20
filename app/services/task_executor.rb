class TaskExecutor
  def self.run(task_class, **arguments)
    # Convert task_class to string if it's a class
    task_class_name = task_class.is_a?(Class) ? task_class.to_s : task_class
    # Get the actual class for validation
    task_class_constant = task_class_name.constantize

    # Extract label from arguments before validation
    label = arguments.delete(:label)

    # Validate arguments
    validate_arguments(task_class_constant, arguments)

    task_execution = TaskExecution.create!(
      task_class: task_class_name,
      arguments: arguments,
      label: label || task_class_constant.to_s.underscore.humanize
    )

    # Create TaskActionLogs for all steps upfront
    task_class_constant.steps_list.each_with_index do |step, index|
      TaskActionLog.create!(
        task_execution: task_execution,
        step_index: index,
        step_label: step[:label],
        status: "queued"
      )
    end

    TaskStepJob.perform_later(task_execution.id, 0)
    task_execution
  end

  private

  def self.validate_arguments(task_class, arguments)
    # Convert all keys to symbols for comparison
    argument_keys = arguments.transform_keys(&:to_sym).keys
    valid_keys = task_class.arguments_list.keys

    # Check for unknown arguments
    unknown_args = argument_keys - valid_keys
    if unknown_args.any?
      raise ArgumentError, "Unknown arguments: #{unknown_args.join(', ')}. Valid arguments are: #{valid_keys.join(', ')}"
    end

    # Validate argument types if needed
    arguments.each do |key, value|
      # Add type validation here if needed
      # For example, if certain arguments must be strings or integers
    end
  end
end
