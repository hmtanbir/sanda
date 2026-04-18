require 'rails_helper'

RSpec.describe EncryptionService do
  let(:plain_text) { "secret message" }
  let(:hex_key) { "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('API_ENCRYPTION_KEY').and_return(hex_key)
  end

  describe '.encrypt and .decrypt' do
    it 'encrypts and decrypts correctly' do
      encrypted = described_class.encrypt(plain_text)
      expect(encrypted).not_to eq(plain_text)
      
      decrypted = described_class.decrypt(encrypted)
      expect(decrypted).to eq(plain_text)
    end

    it 'raises error for too short payload during decryption' do
      expect {
        described_class.decrypt(Base64.strict_encode64("too short"))
      }.to raise_error("Payload too short")
    end
  end

  describe '.encryption_enabled?' do
    it 'returns true when env is "true"' do
      allow(ENV).to receive(:[]).with('API_PAYLOAD_ENCRYPTION_ENABLED').and_return('true')
      expect(described_class.encryption_enabled?).to be true
    end

    it 'returns false when env is not "true"' do
      allow(ENV).to receive(:[]).with('API_PAYLOAD_ENCRYPTION_ENABLED').and_return('false')
      expect(described_class.encryption_enabled?).to be false
    end
  end

  describe '.encryption_key (private)' do
    context 'when key is missing' do
      before do
        allow(ENV).to receive(:[]).with('API_ENCRYPTION_KEY').and_return(nil)
      end

      it 'raises an error' do
        expect {
          described_class.send(:encryption_key)
        }.to raise_error("API_ENCRYPTION_KEY is required when encryption is enabled")
      end
    end

    context 'when key is not a 64-char hex string' do
      let(:simple_key) { "shortkey" }

      before do
        allow(ENV).to receive(:[]).with('API_ENCRYPTION_KEY').and_return(simple_key)
      end

      it 'pads the key to 32 bytes' do
        key = described_class.send(:encryption_key)
        expect(key.length).to eq(32)
        expect(key).to eq(simple_key.ljust(32, "0"))
      end
    end
  end
end
