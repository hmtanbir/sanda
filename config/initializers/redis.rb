$redis_user_db = Redis.new(url: ENV["REDIS_URL"]) { "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_USER_DB']}" }
