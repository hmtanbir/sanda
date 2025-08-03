class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    user = User.find_by(email: user_params.dig(:email), deleted_at: nil)

    render_json_response(:not_found, I18n.t("api.errors.invalid_email")) and return unless user

    if user&.authenticate(user_params.dig(:password))
      token = JsonWebToken.encode(user_id: user.id)
      render_json_response(:ok, I18n.t("data.success.fetched"), { token: token })
    else
      render_json_response(:unauthorized, I18n.t("api.errors.invalid_password"))
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
