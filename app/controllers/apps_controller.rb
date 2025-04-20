class AppsController < ApplicationController
  def index
    @system_apps = App.where(system: true)
    @user_apps = App.where(system: false)
  end
end
