class RedisUserService
  def initialize(user)
    @user = user
  end

  def save
    $redis_user_db.set("users:#{@user.id}", {
      id: @user.id,
      name: @user.email,
      role: @user.role,
      created_at: @user.created_at,
      updated_at: @user.updated_at,
      deleted_at: nil
    }.to_json)
  end

  def get_user_data
    redis_data = $redis_user_db.get("users:#{@user}")

    if redis_data.nil?
      raise StandardError, I18n.t("errors.redis_data_not_found")
    end

    User.new(JSON.parse(redis_data))
  end
  def delete
    $redis_user_db.del("users:#{@user.id}")
  end
end
