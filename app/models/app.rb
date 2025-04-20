class App < ApplicationRecord
  validates :name, presence: true,
                  uniqueness: { case_sensitive: false },
                  format: { with: /\A[a-z0-9_-]+\z/, message: "only allows lowercase letters, numbers, hyphens and underscores" }
  validates :image, presence: true,
                   format: {
                     with: /\A(?:(?=[^:\/]{1,253})(?!-)[a-zA-Z0-9-]{1,63}(?<!-)(?:\.(?!-)[a-zA-Z0-9-]{1,63}(?<!-))*(?::[0-9]{1,5})?\/)?(?:(?![._-])(?:[a-z0-9._-]*)(?<![._-])(?:\/(?![._-])[a-z0-9._-]*(?<![._-]))*)(?::(?![.-])[a-zA-Z0-9_.-]{1,128})?\z/,
                     message: "must be a valid Docker image name or URL with optional tag"
                   }
  validates :description, presence: true, length: { maximum: 200 }
  validates :restart_policy, presence: true, inclusion: { in: %w[no always unless-stopped on-failure] }
  validates :health_check_path, presence: true, format: { with: /\A\/.*\z/, message: "must start with a forward slash" }
  validates :port, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 65536 }
  validate :validate_port_mappings

  attribute :system, :boolean, default: false
  attribute :rolling_update, :boolean, default: false
  attribute :restart_policy, :string, default: "unless-stopped"
  attribute :health_check_path, :string, default: "/"
  attribute :port, :integer, default: 3000
  attribute :port_mappings, :json, default: []
  attribute :description, :string, default: "No description provided"

  private

  def validate_port_mappings
    return if port_mappings.blank?

    unless port_mappings.is_a?(Array)
      errors.add(:port_mappings, "must be an array")
      return
    end

    port_mappings.each do |mapping|
      unless mapping =~ /\A\d{1,5}:\d{1,5}\z/
        errors.add(:port_mappings, "each mapping must be in the format 'host_port:container_port'")
        return
      end

      host_port, container_port = mapping.split(":")
      unless host_port.to_i.between?(1, 65535) && container_port.to_i.between?(1, 65535)
        errors.add(:port_mappings, "ports must be between 1 and 65535")
      end
    end
  end
end
