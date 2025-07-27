class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, :authorization_request,  only: [ :create ]
  before_action :set_user, only: %i[show update destroy]
  before_action :users_data, only: :index
  before_action :user_data, only: :show

  # GET /api/v1/users
  def index;end

  # GET /api/v1/users/:id
  def show;end

  # POST /api/v1/users
  def create
    user = User.new(user_params)
    user.role = :user
    if user.save
      RedisUserService.new(user).save
      render_json_response(:created, I18n.t("data.success.created"), serialized_data(user))
    else
      render_json_response(:unprocessable_content, user.errors.full_messages)
    end
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    @user.update(user_params)
    render_json_response(:ok, I18n.t("data.success.updated"), serialized_data(@user))
  rescue ActiveRecord::RecordInvalid => error
    handle_exception(error)
  end

  def destroy
    @user.update_attribute(:deleted_at, DateTime.now)
    RedisUserService.new(@user).delete
    render_json_response(:ok, I18n.t("data.success.deleted"))
  rescue ActiveRecord::RecordNotDestroyed => error
    handle_exception(error)
  end

  private

  def set_user
    unless @current_user.admin? || params[:id].to_i == @current_user.id
      return render_json_response(:unauthorized, I18n.t("api.errors.unauthorized"))
    end

    @user = User.find(params[:id])
  end

  def user_params
    permitted = [ :name, :email, :password ]
    permitted << :role if @current_user&.admin?
    params.require(:user).permit(permitted)
  end

  def users_data
    data, pagination = PaginationService.new(fetch_users, pagination_info).get_paginated_data
    render_json_response(:ok, I18n.t("data.success.fetched"), data, pagination)
  end

  def user_data
    serialized_data = serialized_data(@user)
    render_json_response(:ok, I18n.t("data.success.fetched"), serialized_data)
  end

  def serialized_data(user)
    UserSerializer.new(user).serializable_hash
  end

  def fetch_users
    role = params[:role]
    role ? User.role_users(role) : User.all_users
  end
end
