class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authenticate_user!
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  rescue_from StandardError, with: :handle_internal_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  private

  def handle_internal_server_error(exception)
    render file: Rails.public_path.join("500.html"), status: :internal_server_error, layout: false
  end

  def handle_not_found
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
