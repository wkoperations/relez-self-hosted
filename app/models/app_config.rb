class AppConfig < ApplicationRecord
  # encrypts :value

  validates :key, presence: true, uniqueness: true
  validates :value_type, presence: true, inclusion: { in: %w[string integer float boolean text] }

  before_validation :set_value_type

  def self.get(key)
    config = find_by(key: key)
    return nil unless config

    case config.value_type
    when "integer"
      config.value.to_i
    when "float"
      config.value.to_f
    when "boolean"
      config.value == "true"
    else
      config.value
    end
  end

  def self.set(key, value)
    config = find_or_initialize_by(key: key)
    config.value = value.to_s
    config.save!
  end

  private

  def set_value_type
    return if value.blank?

    self.value_type = case value
    when /\A-?\d+\z/
      "integer"
    when /\A-?\d*\.\d+\z/
      "float"
    when "true", "false"
      "boolean"
    when String
      value.length > 255 ? "text" : "string"
    end
  end
end
