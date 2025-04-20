class DockerService
  class Error < StandardError; end

  private

  def docker(*args, **options)
    command = build_docker_command(args, options)
    execute_command(command)
  end

  def build_docker_command(args, options)
    cmd_parts = [ "docker" ]

    # Convert array of args into command parts (e.g. [:container, :start, "traefik"] => "docker container start traefik")
    args.each do |arg|
      cmd_parts << case arg
      when Symbol
        arg.to_s.tr("_", "-") # Convert underscores to dashes for CLI commands
      when Array
        arg.join(" ")
      else
        arg.to_s
      end
    end

    # Add options as flags
    options.each do |key, value|
      flag = "--#{key.to_s.tr("_", "-")}"

      case value
      when true
        cmd_parts << flag
      when false, nil
        # Skip false/nil flags
      when Array
        value.each { |v| cmd_parts << "#{flag}=#{v}" }
      else
        cmd_parts << "#{flag}=#{value}"
      end
    end

    cmd_parts.join(" ")
  end

  def execute_command(command)
    output = `#{command} 2>&1`
    status = $?.exitstatus

    if status.zero?
      output.strip
    else
      raise Error, "Docker command failed (status #{status}): #{output}"
    end
  end

  # Helper methods for common docker commands
  def container(*args, **options)
    docker(:container, *args, **options)
  end

  def image(*args, **options)
    docker(:image, *args, **options)
  end

  def network(*args, **options)
    docker(:network, *args, **options)
  end

  def volume(*args, **options)
    docker(:volume, *args, **options)
  end

  def compose(*args, **options)
    docker(:compose, *args, **options)
  end
end
