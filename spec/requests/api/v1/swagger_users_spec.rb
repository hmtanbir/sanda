require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request do
  let(:admin_user) { create(:user, role: 'admin') }
  let(:regular_user) { create(:user, role: 'user') }

  path '/api/v1/registration' do
    post 'Registers a new user' do
      tags 'Registration'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'John Doe' },
              email: { type: :string, example: 'john@example.com' },
              password: { type: :string, example: 'password123' },
              role: { type: :string, example: 'user' }
            },
            required: %w[name email password]
          }
        },
        required: [ 'user' ]
      }

      response '201', 'Created successfully' do
        let(:user_params) { { user: { name: 'John Doe', email: 'john.doe@example.com', password: 'password123' } } }
        run_test!
      end

      response '422', 'Validation errors' do
        let(:user_params) { { user: { name: '', email: 'john@example.com', password: 'password123' } } }
        run_test!
      end
    end
  end

  path '/api/v1/users' do
    get 'Retrieves paginated users list' do
      tags 'Users'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :role, in: :query, type: :string, description: 'Role to filter by', required: false
      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page', required: false

      response '200', 'Users fetched successfully' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin_user.id)}" }
        let(:role) { 'user' }
        before { create_list(:user, 3) }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'invalid' }
        let(:role) { 'user' }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'User ID', required: true

    get 'Retrieves a user' do
      tags 'Users'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'User fetched successfully' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:id) { regular_user.id }
        run_test!
      end

      response '404', 'User not found' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin_user.id)}" }
        let(:id) { 0 }
        run_test!
      end
    end

    put 'Updates a user' do
      tags 'Users'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, example: 'jane@example.com' }
            }
          }
        }
      }

      response '200', 'User updated successfully' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:id) { regular_user.id }
        let(:user_params) { { user: { name: 'Jane Updated' } } }
        run_test!
      end
    end

    patch 'Updates a user' do
      tags 'Users'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, example: 'jane@example.com' }
            }
          }
        }
      }

      response '200', 'User updated successfully' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:id) { regular_user.id }
        let(:user_params) { { user: { name: 'Jane Patched' } } }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'User deleted successfully' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin_user.id)}" }
        let(:id) { regular_user.id }
        run_test!
      end
    end
  end
end
