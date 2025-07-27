class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create ]
  before_action :set_user, only: %i[show update destroy]

  # GET /api/v1/users
  def index
    all_users_data
  end

  # GET /api/v1/users/:id
  def show
    user_data
  end

  # POST /api/v1/users
  def create
    user = User.new(user_params)
    if user.save!
      RedisUserService.new(user).save
      render_json_response(:created, I18n.t("data.success.created"), serialized_data(user))
    else
      render_json_response(:unprocessable_entity, user.errors.full_messages)
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
    render_json_response(:ok, I18n.t("data.success.deleted"))
  rescue ActiveRecord::RecordNotDestroyed => error
    handle_exception(error)
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound => error
    handle_record_not_found(error)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def all_users_data
    users = User.all_user
    data, pagination = PaginationService.new(users, pagination_info).get_paginated_data
    render_json_response(:ok, I18n.t("data.success.fetched"), data, pagination)
  end

  def user_data
    serialized_data = serialized_data(@user)
    render_json_response(:ok, I18n.t("data.success.fetched"), serialized_data)
  end

  def serialized_data(user)
    UserSerializer.new(user).serializable_hash
  end
end
