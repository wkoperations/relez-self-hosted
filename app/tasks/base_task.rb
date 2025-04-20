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
  def initialize(arguments:)
    @arguments = arguments.transform_keys(&:to_sym)
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
