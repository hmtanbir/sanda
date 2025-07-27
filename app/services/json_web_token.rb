class JsonWebToken
  SECRET_KEY = ENV["SECRET_KEY"] || Rails.application.secret_key_base
  EXPIRE_KEY = ENV["JWT_EXPIRE"] || 24.hours.from_now

  def self.encode(payload, exp = EXPIRE_KEY)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError
    nil
  end
end
