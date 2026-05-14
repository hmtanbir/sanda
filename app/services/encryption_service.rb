class EncryptionService
  def self.encrypt(plain_text)
    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.encrypt
    cipher.key = encryption_key
    iv = cipher.random_iv

    ciphertext = cipher.update(plain_text) + cipher.final
    auth_tag = cipher.auth_tag

    # Combine IV + Ciphertext + AuthTag
    combined = iv + ciphertext + auth_tag

    # Strict encode is used to avoid newlines in base64 payload
    Base64.strict_encode64(combined)
  end

  def self.decrypt(base64_payload)
    # GCM Payload structure: IV (12 bytes) + Ciphertext + AuthTag (16 bytes)
    decoded = Base64.decode64(base64_payload)

    if decoded.bytesize < 28
      raise "Payload too short"
    end

    iv = decoded.byteslice(0, 12)
    auth_tag = decoded.byteslice(-16, 16)
    ciphertext = decoded.byteslice(12, decoded.bytesize - 28)

    cipher = OpenSSL::Cipher.new("aes-256-gcm")
    cipher.decrypt
    cipher.key = encryption_key
    cipher.iv = iv
    cipher.auth_tag = auth_tag

    # update + final will raise an error if auth_tag doesn't match
    cipher.update(ciphertext) + cipher.final
  end

  def self.encryption_enabled?
    ENV["API_PAYLOAD_ENCRYPTION_ENABLED"] == "true"
  end

  private

  def self.encryption_key
    key = ENV["API_ENCRYPTION_KEY"].to_s
    if key.length == 0
      raise "API_ENCRYPTION_KEY is required when encryption is enabled"
    end

    # If the key is a hex string (length 64), unhex it:
    if key.length == 64 && key =~ /^[0-9a-f]+$/i
      [ key ].pack("H*")
    else
      # Pad or truncate exactly to 32 bytes
      key.ljust(32, "0")[0, 32]
    end
  end
end
