class HelloWorldTask < BaseTask
  argument :name, default: "Gunnar"

  step "Initialize" do
    puts "Starting Hello World task for #{name}"
    sleep 2
    puts "Initializing task execution environment..."
    sleep 2
    puts "Loading cluster configuration..."
    sleep 2
    puts "Verifying cluster connectivity..."
    sleep 2
    puts "Cluster is ready for task execution"
  end

  step "Prepare" do
    puts "Preparing cluster for updates..."
    sleep 2
    puts "Checking current server count..."
    sleep 2
    puts "Validating server configuration..."
    sleep 2
    puts "Configuration validation complete"
  end

  step "Update" do
    puts "Initiating server count update..."
    sleep 2
    puts "Preparing database transaction..."
    sleep 2
    puts "Verifying update..."
    sleep 2
    puts "Server count update confirmed"
  end

  step "Finalize" do
    puts "Starting finalization phase..."
    sleep 2
    puts "Cleaning up temporary resources..."
    sleep 2
    puts "Updating cluster metadata..."
    sleep 2
    puts "Generating completion report..."
    sleep 2
    puts "Hello World task completed successfully!"
    sleep 2
    puts "Task execution finished at #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
  end
end
