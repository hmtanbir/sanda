require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { message: "ok" }
    end

    def create
      render json: { result: cast_boolean(params[:value]) }
    end
  end

  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:gateway_key) { "secret-gateway-key" }

  before do
    allow(ENV).to receive(:[]).and_call_original
    # Default environment
    allow(ENV).to receive(:[]).with('API_GATEWAY_KEY').and_return(nil)
    allow(ENV).to receive(:[]).with('API_PAYLOAD_ENCRYPTION_ENABLED').and_return('false')
  end

  describe '#authenticate_request' do
    context 'when encryption is enabled' do
      let(:hex_key) { "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" }
      
      before do
        allow(ENV).to receive(:[]).with('API_PAYLOAD_ENCRYPTION_ENABLED').and_return('true')
        allow(ENV).to receive(:[]).with('API_ENCRYPTION_KEY').and_return(hex_key)
      end

      it 'decrypts the token from an encrypted payload' do
        # Create an encrypted payload containing a JSON with the token
        payload = { data: { token: token } }.to_json
        encrypted_token = EncryptionService.encrypt(payload)
        
        request.headers['Authorization'] = "Bearer #{encrypted_token}"
        get :index
        
        expect(response).to have_http_status(:ok)
        expect(assigns(:current_user)).to eq(user)
      end

      it 'falls back to raw token if decryption fails' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        
        expect(response).to have_http_status(:ok)
        expect(assigns(:current_user)).to eq(user)
      end
    end

    it 'returns unauthorized when token is invalid' do
      request.headers['Authorization'] = "Bearer invalid_token"
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#verify_api_gateway_key' do
    before do
      allow(ENV).to receive(:[]).with('API_GATEWAY_KEY').and_return(gateway_key)
    end

    it 'returns forbidden if gateway key is missing' do
      get :index
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['message']).to eq('Invalid API Gateway Key')
    end

    it 'returns forbidden if gateway key is incorrect' do
      request.headers['x-api-gateway-key'] = 'wrong-key'
      get :index
      expect(response).to have_http_status(:forbidden)
    end

    it 'proceeds if gateway key is correct' do
      request.headers['x-api-gateway-key'] = gateway_key
      request.headers['Authorization'] = "Bearer #{token}"
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#cast_boolean' do
    before do
      request.headers['Authorization'] = "Bearer #{token}"
    end

    it 'casts "true" to true' do
      post :create, params: { value: "true" }
      expect(JSON.parse(response.body)['result']).to be true
    end

    it 'casts "false" to false' do
      post :create, params: { value: "false" }
      expect(JSON.parse(response.body)['result']).to be false
    end
  end
end
