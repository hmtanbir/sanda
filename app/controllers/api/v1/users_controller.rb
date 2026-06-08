class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [ :registration ]

  before_action :authorize_current_user, only: %i[index]
  before_action :set_user, :authorize_user, only: %i[show update destroy]
  before_action :users_data, only: :index
  before_action :user_data, only: :show

  # GET /api/v1/users
  def index;end

  # GET /api/v1/users/:id
  def show;end

  # GET /api/v1/users/me
  # PATCH /api/v1/users/me
  def me
    if request.patch?
      @current_user.update!(user_params)
      render_json_response(:ok, I18n.t("api.success.updated"), serialized_data(@current_user))
    else
      render_json_response(:ok, I18n.t("api.success.fetched"), serialized_data(@current_user))
    end
  end

  # POST /api/v1/users
  def create
    user = User.new(user_params)
    user.role = :user if user.role.nil?
    if user.save
      render_json_response(:created, I18n.t("api.success.created"), serialized_data(user))
    else
      render_json_response(:unprocessable_content, user.errors.full_messages)
    end
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    @user.update!(user_params)
    render_json_response(:ok, I18n.t("api.success.updated"), serialized_data(@user))
  end

  def destroy
    @user.update_attribute(:deleted_at, DateTime.now)
    render_json_response(:ok, I18n.t("api.success.deleted"))
  rescue ActiveRecord::RecordNotDestroyed => error
    handle_exception(error)
  end

  def registration
    user = User.new(user_params)
    user.role = :user if user.role.nil?
    if user.save
      # Send Slack notification for user registration
      slack_message = "New user registered: #{user.name} (#{user.email})"
      SlackNotification.notify(slack_message, event: :registration)

      render_json_response(:created, I18n.t("api.success.created"), serialized_data(user))
    else
      render_json_response(:unprocessable_content, user.errors.full_messages)
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_json_response(:not_found, I18n.t("api.errors.users.not_found")) unless @user
  end

  def user_params
    permitted = [ :name, :email, :password, :phone, :status, :appwrite_user_id, :appwrite_user_preferences ]
    permitted << :role if @current_user&.admin?
    params.require(:user).permit(permitted)
  end


  def users_data
    last_updated_at = fetch_users.maximum(:updated_at).to_i
    cache_key = [
      "users_index",
      params[:role] || "all",
      params[:deleted] || "false",
      fetch_users.count,
      last_updated_at,
      pagination_info.to_a
    ].join("/")

    ttl = ENV.fetch("API_CACHE_TTL", 3600).to_i.seconds

    data, pagination = Rails.cache.fetch(cache_key, expires_in: ttl) do
      PaginationService.new(fetch_users, pagination_info).get_paginated_data
    end

    render_json_response(:ok, I18n.t("api.success.fetched"), data, pagination)
  end

  def user_data
    ttl = ENV.fetch("API_CACHE_TTL", 3600).to_i.seconds
    data = Rails.cache.fetch(@user, expires_in: ttl) do
      serialized_data(@user)
    end

    render_json_response(:ok, I18n.t("api.success.fetched"), data)
  end

  def fetch_users
    role = params[:role]
    deleted = cast_boolean(params[:deleted])
    role ? User.role_users(role, deleted) : User.all_users(deleted)
  end

  def authorize_current_user
    authorize @current_user, policy_class: UserPolicy
  end

  def authorize_user
    authorize @user, policy_class: UserPolicy
  end
end
