module SetupConcern
  extend ActiveSupport::Concern

  included do
    before_action :ensure_setup_complete
  end

  private

  def ensure_setup_complete
    return if controller_name == "setup"
    redirect_to setup_path if AppConfig.get("provisioned_at").nil?
  end
end
