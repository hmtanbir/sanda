redis_user_url = ENV.fetch("REDIS_URL") {
  "redis://#{ENV.fetch("REDIS_HOST", "localhost")}:#{ENV.fetch("REDIS_PORT", 6379)}/#{ENV.fetch("REDIS_USER_DB", 0)}"
}

$redis_user_db = Redis.new(url: redis_user_url)
