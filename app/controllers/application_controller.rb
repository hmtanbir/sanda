class ApplicationController < ActionController::API
  include Pundit::Authorization
  before_action :authenticate_request, :authorization_request

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
    render_json_response(:not_found, I18n.t("token.not_found")) and return if token.nil?

    begin
      decoded = JsonWebToken.decode(token)
      render_json_response(:unauthorized, I18n.t("token.invalid")) and return if decoded.nil?
      @current_user = RedisUserService.new(decoded[:user_id]).get_user_data
    rescue StandardError => e
      handle_record_not_found(e)
    end
  end

  def authorization_request
    authorize @current_user
  end

  def user_not_authorized
    render_json_response(:forbidden, I18n.t("api.errors.unauthorized"))
  end
end
