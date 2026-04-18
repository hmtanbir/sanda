class ApplicationController < ActionController::API
  include Pundit::Authorization
  before_action :verify_api_gateway_key
  before_action :authenticate_request

  attr_reader :current_user

  rescue_from StandardError, with: :handle_exception
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10

  private

  def handle_record_not_found(exception)
    logger.warn exception.message
    logger.warn exception.backtrace.join "\n"
    render_json_response(:not_found, exception.message)
  end

  def handle_invalid_record(exception)
    logger.warn exception.message
    logger.warn exception.backtrace.join "\n"
    render_json_response(:unprocessable_content, exception.message)
  end

  def handle_exception(exception)
    logger.error exception.message
    logger.error exception.backtrace.join "\n"
    render_json_response(:internal_server_error, exception.message)
  end

  def render_json_response(status, message = "", data = nil, extra = {})
    status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a? Symbol
    response = {
      status: status,
      message: message,
      data: data
    }.merge(extra)
    render json: response, status: status
  end

  def pagination_info
    {
      page: (params[:page].presence || DEFAULT_PAGE).to_i,
      per_page: (params[:per_page].presence || DEFAULT_PER_PAGE).to_i
    }
  end

  def authenticate_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    render_json_response(:not_found, I18n.t("api.errors.token.not_found")) and return if token.nil?

    begin
      # If encryption is enabled, try to decrypt the token first.
      # The user might be sending the entire encrypted response from the login API.
      if EncryptionService.encryption_enabled?
        begin
          decrypted = EncryptionService.decrypt(token)
          parsed = JSON.parse(decrypted)
          # The session API returns { status: 200, message: "...", data: { token: "..." } }
          token = parsed.dig("data", "token") if parsed.is_a?(Hash) && parsed.dig("data", "token").present?
        rescue StandardError
          # If decryption or parsing fails, we assume it's already a raw JWT
        end
      end

      decoded = JsonWebToken.decode(token)
      render_json_response(:unauthorized, I18n.t("api.errors.token.invalid")) and return if decoded.nil?
      @current_user ||= User.find(decoded[:user_id])
      render_json_response(:unauthorized, I18n.t("api.errors.sessions.inactive_user")) and return if @current_user.inactive?
    rescue StandardError => e
      handle_record_not_found(e)
    end
  end

  def user_not_authorized
    render_json_response(:forbidden, I18n.t("api.errors.unauthorized"))
  end

  def serialized_data(data, options = {})
    return data if data.is_a?(Hash) || data.is_a?(Array)
    ActiveModelSerializers::SerializableResource.new(data, options).serializable_hash
  end

  def verify_api_gateway_key
    expected_key = ENV["API_GATEWAY_KEY"]
    return if expected_key.blank?

    provided_key = request.headers["x-api-gateway-key"]

    if provided_key != expected_key
      render_json_response(:forbidden, "Invalid API Gateway Key")
    end
  end

  def cast_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
