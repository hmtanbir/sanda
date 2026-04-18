require 'rails_helper'
require_relative '../../app/middleware/api_payload_encryption'

RSpec.describe ApiPayloadEncryption do
  let(:app) { ->(env) { [ 200, { 'Content-Type' => 'application/json' }, [ response_body.to_json ] ] } }
  let(:middleware) { described_class.new(app) }
  let(:response_body) { { message: "success" } }
  let(:encryption_key) { "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" }
  let(:pack_key) { [ encryption_key ].pack('H*') }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('API_PAYLOAD_ENCRYPTION_ENABLED').and_return(enabled.to_s)
    allow(ENV).to receive(:[]).with('API_ENCRYPTION_KEY').and_return(encryption_key)
  end

  def encrypt(plain_text)
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.encrypt
    cipher.key = pack_key
    iv = cipher.random_iv
    ciphertext = cipher.update(plain_text) + cipher.final
    auth_tag = cipher.auth_tag
    Base64.strict_encode64(iv + ciphertext + auth_tag)
  end

  describe '#call' do
    context 'when encryption is disabled' do
      let(:enabled) { false }
      let(:env) { Rack::MockRequest.env_for('/') }

      it 'returns the original response' do
        status, _, body = middleware.call(env)
        expect(status).to eq(200)
        expect(body).to eq([ { message: "success" }.to_json ])
      end
    end

    context 'when encryption is enabled' do
      let(:enabled) { true }

      context 'with incoming request' do
        it 'decrypts valid json payload' do
          payload = encrypt({ test: "data" }.to_json)
          env = Rack::MockRequest.env_for('/', method: 'POST', input: { payload: payload }.to_json)

          middleware.call(env)

          # Check rack.input was modified
          expect(env['rack.input'].read).to eq({ test: "data" }.to_json)
        end

        it 'decrypts raw string payload' do
          payload = encrypt({ test: "data" }.to_json)
          # Raw base64 string
          env = Rack::MockRequest.env_for('/', method: 'POST', input: "\"#{payload}\"")

          middleware.call(env)

          expect(env['rack.input'].read).to eq({ test: "data" }.to_json)
        end

        it 'decrypts unquoted raw payload' do
          payload = encrypt({ test: "unquoted" }.to_json)
          # Raw base64 string WITHOUT quotes - this triggers JSON::ParserError
          env = Rack::MockRequest.env_for('/', method: 'POST', input: payload)

          middleware.call(env)

          expect(env['rack.input'].read).to eq({ test: "unquoted" }.to_json)
        end

        it 'gracefully bypasses gracefully formatted unencrypted json' do
          env = Rack::MockRequest.env_for('/', method: 'POST', input: { user: "data" }.to_json)
          middleware.call(env)

          expect(env['rack.input'].read).to eq({ user: "data" }.to_json)
        end

        it 'returns 400 on invalid payload' do
          env = Rack::MockRequest.env_for('/', method: 'POST', input: { payload: "invalid" }.to_json)
          status, _, body = middleware.call(env)

          expect(status).to eq(400)
          expect(JSON.parse(body.first)['error']).to eq('Invalid encrypted payload')
        end
      end

      context 'with outgoing response' do
        let(:env) { Rack::MockRequest.env_for('/') }

        it 'encrypts the json response' do
          status, _, body = middleware.call(env)

          expect(status).to eq(200)
          parsed_body = JSON.parse(body.first)
          expect(parsed_body).to have_key('data')

          # decrypt it to verify
          decoded = Base64.decode64(parsed_body['data'])
          cipher = OpenSSL::Cipher.new('aes-256-gcm')
          cipher.decrypt
          cipher.key = pack_key
          cipher.iv = decoded.byteslice(0, 12)
          cipher.auth_tag = decoded.byteslice(-16, 16)
          decrypted = cipher.update(decoded.byteslice(12, decoded.bytesize - 28)) + cipher.final

          expect(decrypted).to eq({ message: "success" }.to_json)
        end

        it 'returns 500 if encryption fails' do
          allow(EncryptionService).to receive(:encrypt).and_raise("Key error")
          status, _, body = middleware.call(env)

          expect(status).to eq(500)
          expect(JSON.parse(body.first)['error']).to eq('Internal Server Error during encryption')
        end
      end

      context 'with non-json response' do
        let(:app) { ->(env) { [ 200, { 'Content-Type' => 'text/html' }, [ "<html></html>" ] ] } }
        let(:env) { Rack::MockRequest.env_for('/') }

        it 'does not encrypt the response' do
          status, _, body = middleware.call(env)
          expect(status).to eq(200)
          expect(body).to eq([ "<html></html>" ])
        end
      end
    end
  end
end
