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
    @user.update(user_params)
    render_json_response(:ok, I18n.t("api.success.updated"), serialized_data(@user))
  rescue ActiveRecord::RecordInvalid => error
    handle_exception(error)
  end

  def destroy
    @user.update_attribute(:deleted_at, DateTime.now)
    render_json_response(:ok, I18n.t("api.success.deleted"))
  rescue ActiveRecord::RecordNotDestroyed => error
    handle_exception(error)
  end

  def registration
    create
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_json_response(:not_found, I18n.t("api.errors.users.not_found")) unless @user
  end

  def user_params
    permitted = [ :name, :email, :password ]
    permitted << :role if @current_user&.admin?
    params.require(:user).permit(permitted)
  end

  def users_data
    data, pagination = PaginationService.new(fetch_users, pagination_info).get_paginated_data
    render_json_response(:ok, I18n.t("api.success.fetched"), data, pagination)
  end

  def user_data
    serialized_data = serialized_data(@user)
    render_json_response(:ok, I18n.t("api.success.fetched"), serialized_data)
  end

  def fetch_users
    role = params[:role]
    role ? User.role_users(role) : User.all_users
  end

  def authorize_current_user
    authorize @current_user, policy_class: UserPolicy
  end

  def authorize_user
    authorize @user, policy_class: UserPolicy
  end
end
