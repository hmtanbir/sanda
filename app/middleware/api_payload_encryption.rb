require "openssl"
require "base64"
require "json"

class ApiPayloadEncryption
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless EncryptionService.encryption_enabled?

    # 1. Decrypt incoming request if there is a body
    req = Rack::Request.new(env)
    if req.post? || req.put? || req.patch? || req.delete?
      body_content = req.body.read
      req.body.rewind # Rewind so it can be read again if needed

      if body_content.present?
        begin
          payload = extract_payload(body_content)
          if payload
            decrypted_body = EncryptionService.decrypt(payload)
            # Replace rack.input so Rails parses the decrypted json
            env["rack.input"] = StringIO.new(decrypted_body)
            # Update CONTENT_LENGTH since we changed the body length
            env["CONTENT_LENGTH"] = decrypted_body.bytesize.to_s
            # If we decrypted successfully, it should be treated as JSON
            env["CONTENT_TYPE"] = "application/json"
          end
        rescue StandardError => e
          return [ 400, { "Content-Type" => "application/json" }, [ { error: "Invalid encrypted payload", details: e.message }.to_json ] ]
        end
      end
    end

    # 2. Process request via Rails application
    status, headers, response = @app.call(env)

    # 3. Encrypt outgoing response
    # We should only encrypt JSON responses so we don't accidentally encrypt files
    content_type = headers["Content-Type"].to_s
    if content_type.include?("application/json")
      response_body = []
      response.each { |part| response_body << part }
      # Rack specification requires calling close if the response responds to it
      response.close if response.respond_to?(:close)

      response_string = response_body.join

      if response_string.present?
        begin
          encrypted_data = EncryptionService.encrypt(response_string)
          new_body = { data: encrypted_data }.to_json

          headers["Content-Length"] = new_body.bytesize.to_s
          headers["Content-Type"] = "application/json; charset=utf-8"

          response = [ new_body ]
        rescue StandardError => e
          return [ 500, { "Content-Type" => "application/json" }, [ { error: "Internal Server Error during encryption" }.to_json ] ]
        end
      end
    end

    [ status, headers, response ]
  end

  private

  def extract_payload(body_content)
    # The client might send `{"payload": "..."}` or just `"encrypted_base64_string"`
    begin
      parsed = JSON.parse(body_content)
      return parsed["payload"] if parsed.is_a?(Hash) && parsed.key?("payload")

      # If the body is a raw JSON string e.g. "base64_string_here"
      return parsed if parsed.is_a?(String)

      # If it's valid JSON but without the "payload" key,
      # we gracefully assume it's a standard unencrypted request payload
      # (Useful for Postman/cURL debugging)
      return nil
    rescue JSON::ParserError
      # Not JSON, proceed to treat as raw unquoted string
    end

    # Assume the raw body is the base64 string
    body_content.strip.delete_prefix('"').delete_suffix('"')
  end
end
