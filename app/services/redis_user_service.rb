class RedisUserService
  def initialize(user)
    @user = user
  end

  def save
    $redis_user_db.set("users:#{@user.id}", {
      id: @user.id,
      name: @user.email,
      created_at: @user.created_at,
      updated_at: @user.updated_at,
      deleted_at: nil
    }.to_json)
  end

  def get_user_data
    redis_data = $redis_user_db.get("users:#{@user}")

    if redis_data.nil?
      raise JWT::DecodeError, "Data not found in Redis DB"
    end

   JSON.parse(redis_data)
  end
end
