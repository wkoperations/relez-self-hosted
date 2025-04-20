class SetupForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :hostname, :string
  attribute :admin_email, :string
  attribute :timezone, :string

  validates :hostname, presence: true, format: {
    with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}\z/i,
    message: "must be a valid hostname (e.g., server.example.com)"
  }
  validates :admin_email, presence: true, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "must be a valid email address"
  }
  validates :timezone, presence: true, inclusion: {
    in: ActiveSupport::TimeZone.all.map(&:name),
    message: "must be a valid timezone"
  }

  def self.load_defaults
    new(
      hostname: Socket.gethostname,
      timezone: Time.zone.name,
      admin_email: "admin@#{Socket.gethostname}"
    )
  end

  def persisted?
    AppConfig.get("provisioned_at").present?
  end

  def save
    return false unless valid?

    AppConfig.set("hostname", hostname)
    AppConfig.set("admin_email", admin_email)
    AppConfig.set("timezone", timezone)
    AppConfig.set("provisioned_at", Time.current)

    true
  end
end
