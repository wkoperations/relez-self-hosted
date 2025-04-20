class HelloWorldTask < BaseTask
  argument :name, default: "Gunnar"

  step "Initialize" do
    log "Starting Hello World task for #{name}"
    sleep 2
    log "Initializing task execution environment..."
    sleep 2
    log "Loading cluster configuration..."
    sleep 2
    log "Verifying cluster connectivity..."
    sleep 2
    log "Cluster is ready for task execution"
  end

  step "Prepare" do
    log "Preparing cluster for updates..."
    sleep 2
    log "Checking current server count..."
    sleep 2
    log "Validating server configuration..."
    sleep 2
    log "Configuration validation complete"
  end

  step "Update" do
    log "Initiating server count update..."
    sleep 2
    log "Preparing database transaction..."
    sleep 2
    log "Verifying update..."
    sleep 2
    log "Server count update confirmed"
  end

  step "Finalize" do
    log "Starting finalization phase..."
    sleep 2
    log "Cleaning up temporary resources..."
    sleep 2
    log "Updating cluster metadata..."
    sleep 2
    log "Generating completion report..."
    sleep 2
    log "Hello World task completed successfully!"
    sleep 2
    log "Task execution finished at #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
  end
end
