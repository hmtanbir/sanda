require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request do
  let(:admin_user) { create(:user, role: 'admin') }
  let(:regular_user) { create(:user, role: 'user') }

  path '/api/v1/registration' do
    post 'Registers a new user' do
      tags 'Registration'
      security [ { x_api_gateway_key: [] } ]
      consumes 'application/json'
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'John Doe' },
              email: { type: :string, example: 'john@example.com' },
              password: { type: :string, example: 'password123' },
              status: { type: :string, example: 'active' },
              role: { type: :string, example: 'user' }
            },
            required: %w[name email password]
          }
        },
        required: [ 'user' ]
      }

      response '201', 'Created successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 201 },
            message: { type: :string, example: 'Successfully data created' },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                name: { type: :string, example: 'John Doe' },
                email: { type: :string, example: 'john.doe@example.com' },
                role: { type: :string, example: 'user' },
                status: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                deleted_at: { type: :string, format: 'date-time', nullable: true }
               }
              }
            }
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
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }
      parameter name: :role, in: :query, type: :string, description: 'Role to filter by', required: false
      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page', required: false

      response '200', 'Users fetched successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Successfully data fetched' },
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer, example: 1 },
                  name: { type: :string, example: 'Alice' },
                  email: { type: :string, example: 'alice@example.com' },
                  role: { type: :string, example: 'user' },
                  status: { type: :string, nullable: true },
                  created_at: { type: :string, format: 'date-time' },
                  updated_at: { type: :string, format: 'date-time' },
                  deleted_at: { type: :string, format: 'date-time', nullable: true }
                 }
                }
              },
              pagination: {
                type: :object,
                properties: {
                  current_page: { type: :integer, example: 1 },
                  per_page: { type: :integer, example: 10 },
                  total_pages: { type: :integer, example: 1 },
                  total_count: { type: :integer, example: 3 }
                }
              }
            }
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

  path '/api/v1/users/me' do
    get 'Retrieves current logged in user details' do
      tags 'Users'
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }

      response '200', 'User details fetched successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Successfully data fetched' },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                name: { type: :string, example: 'Alice' },
                email: { type: :string, example: 'alice@example.com' },
                role: { type: :string, example: 'user' },
                status: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                deleted_at: { type: :string, format: 'date-time', nullable: true }
              }
            }
          }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'invalid' }
        run_test!
      end
    end

    patch 'Updates current logged in user details' do
      tags 'Users'
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      consumes 'application/json'
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, example: 'jane@example.com' },
              status: { type: :string, example: 'active' }
            }
          }
        }
      }

      response '200', 'User updated successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Successfully data updated' },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                name: { type: :string, example: 'Jane Patched' },
                email: { type: :string, example: 'jane@example.com' },
                role: { type: :string, example: 'user' },
                status: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                deleted_at: { type: :string, format: 'date-time', nullable: true }
              }
            }
          }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:user_params) { { user: { name: 'Jane Patched' } } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { 'invalid' }
        let(:user_params) { { user: { name: 'Jane Patched' } } }
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:user_params) { { user: { name: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'User ID', required: true

    get 'Retrieves a user' do
      tags 'Users'
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }

      response '200', 'User fetched successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Successfully data fetched' },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                name: { type: :string, example: 'Alice' },
                email: { type: :string, example: 'alice@example.com' },
                role: { type: :string, example: 'user' },
                status: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                deleted_at: { type: :string, format: 'date-time', nullable: true }
              }
            }
          }
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
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      consumes 'application/json'
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, example: 'jane@example.com' },
              status: { type: :string, example: 'active' }
            }
          }
        }
      }

      response '200', 'User updated successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Successfully data updated' },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                name: { type: :string, example: 'Jane Updated' },
                email: { type: :string, example: 'jane@example.com' },
                role: { type: :string, example: 'user' },
                status: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                deleted_at: { type: :string, format: 'date-time', nullable: true }
              }
            }
          }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:id) { regular_user.id }
        let(:user_params) { { user: { name: 'Jane Updated' } } }
        run_test!
      end
    end

    patch 'Updates a user' do
      tags 'Users'
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      consumes 'application/json'
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, example: 'jane@example.com' },
              status: { type: :string, example: 'active' }
            }
          }
        }
      }

      response '200', 'User updated successfully' do
        schema type: :object,
          properties: {
            status: { type: :integer, example: 200 },
            message: { type: :string, example: 'Successfully data updated' },
            data: {
              type: :object,
              properties: {
                id: { type: :integer, example: 1 },
                name: { type: :string, example: 'Jane Patched' },
                email: { type: :string, example: 'jane@example.com' },
                role: { type: :string, example: 'user' },
                status: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                deleted_at: { type: :string, format: 'date-time', nullable: true }
              }
            }
          }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: regular_user.id)}" }
        let(:id) { regular_user.id }
        let(:user_params) { { user: { name: 'Jane Patched' } } }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      security [ { bearer_auth: [], x_api_gateway_key: [] } ]
      produces 'application/json'
      let(:'x-api-gateway-key') { 'test-gateway-key' }

      response '200', 'User deleted successfully' do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin_user.id)}" }
        let(:id) { regular_user.id }
        run_test!
      end
    end
  end
end
