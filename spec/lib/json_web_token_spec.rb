require 'rails_helper'

RSpec.describe JsonWebToken do
  let(:payload) { { user_id: 123 } }

  describe ".encode" do
    it "returns a JWT string" do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
    end

    it "adds an expiration to the payload" do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:exp]).to be_present
    end
  end

  describe ".decode" do
    it "decodes the token back to original payload" do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded[:user_id]).to eq(payload[:user_id])
    end

    it "returns nil for an invalid token" do
      decoded = described_class.decode("invalid.token.value")
      expect(decoded).to be_nil
    end

    it "returns nil for expired token" do
      token = described_class.encode(payload, 1.second.ago)
      sleep 1
      decoded = described_class.decode(token)
      expect(decoded).to be_nil
    end
  end
end
