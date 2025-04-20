class DashboardController < ApplicationController
  def index
    @app_configs = AppConfig.all
    @server_metrics = {
      cpu_usage: 45.2,
      memory_usage: 78.5,
      disk_usage: 62.3,
      network_in: 125.4,
      network_out: 89.7,
      uptime: 7.days + 3.hours + 45.minutes
    }
  end
end
