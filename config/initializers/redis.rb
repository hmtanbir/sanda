redis_url = ENV.fetch("REDIS_URL") {
  password = ENV["REDIS_PASSWORD"].present? ? ":#{ENV["REDIS_PASSWORD"]}@" : ""
  "redis://#{password}#{ENV.fetch("REDIS_HOST", "localhost")}:#{ENV.fetch("REDIS_PORT", 6379)}/#{ENV.fetch("REDIS_DB", 0)}"
}

$redis = Redis.new(url: redis_url)
