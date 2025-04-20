class SetupController < ApplicationController
  skip_before_action :ensure_setup_complete, only: [ :show, :create ]
  before_action :ensure_setup_complete, only: [ :edit, :update ]
  layout -> { action_name.in?(%w[show create]) ? "setup" : "application" }

  def show
    redirect_to root_path if AppConfig.get("provisioned_at").present?
    @form = SetupForm.load_defaults
  end

  def create
    @form = SetupForm.new(setup_params)

    if @form.save
      redirect_to root_path, notice: "Server setup complete!"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def edit
    @form = SetupForm.new(
      hostname: AppConfig.get("hostname"),
      admin_email: AppConfig.get("admin_email"),
      timezone: AppConfig.get("timezone")
    )
  end

  def update
    @form = SetupForm.new(setup_params)

    if @form.save
      redirect_to root_path, notice: "Server settings updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setup_params
    params.require(:setup).permit(:hostname, :admin_email, :timezone)
  end
end
