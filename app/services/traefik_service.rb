class TraefikService < DockerService
  def start
    container :start, "traefik"
  end

  def stop
    container :stop, "traefik"
  end

  def restart
    container :restart, "traefik"
  end

  def logs(follow: false, tail: 100)
    container :logs, "traefik", follow: follow, tail: tail
  end

  def run(version: "v2.10")
    container :run,
      "-d",  # Detached mode
      "--name", "traefik",
      "-p", "80:80",
      "-p", "443:443",
      "-v", "/var/run/docker.sock:/var/run/docker.sock",
      "traefik:#{version}"
  end

  def remove(force: false)
    container :rm, "traefik", force: force
  end

  def status
    container :inspect, "traefik", format: "{{.State.Status}}"
  rescue Error
    "not_found"
  end
end
