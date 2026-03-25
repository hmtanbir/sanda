require 'swagger_helper'

RSpec.describe 'API V1 Sessions', type: :request do
  path '/api/v1/sessions' do
    post 'Login' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: %w[email password]
          }
        },
        required: ['user']
      }

      response '200', 'Logs in a user successfully' do
        let(:user_record) { create(:user, email: 'test@example.com', password: 'password123') }
        let(:user_params) { { user: { email: user_record.email, password: 'password123' } } }
        run_test!
      end

      response '401', 'Invalid password' do
        let(:user_record) { create(:user, email: 'test@example.com', password: 'password123') }
        let(:user_params) { { user: { email: user_record.email, password: 'wrongpassword' } } }
        run_test!
      end

      response '404', 'Invalid email' do
        let(:user_params) { { user: { email: 'nonexistent@example.com', password: 'password123' } } }
        run_test!
      end
    end
  end
end
