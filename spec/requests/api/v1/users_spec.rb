require 'rails_helper'

RSpec.describe "Api::V1::UsersController", type: :request do
  let(:admin_user) { create(:user, role: "admin") }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }

  let(:token) { JsonWebToken.encode(user_id: user2.id) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_user.id) }
  let(:user_auth_headers) { { "Authorization" => "Bearer #{token}" } }
  let(:admin_auth_headers) { { "Authorization" => "Bearer #{admin_token}" } }

  let(:user_params) do
    {
      name: "John Doe",
      email: "john@example.com",
      password: "password123",
      role: "user"
    }
  end

  describe "GET /api/v1/users" do
    context 'authorized current users without role params' do
      before do
        allow(PaginationService).to receive(:new)
                                      .and_return(double(get_paginated_data: [ [ admin_user, user2, user3 ], { total: 3 } ]))
      end

      it "returns paginated list of users for authorized current users" do
        get "/api/v1/users", headers: admin_auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.success.fetched"))
        expect(json["data"].length).to eq(3)
      end
    end

    context 'authorized current users with user role params' do
      before do
        allow(PaginationService).to receive(:new)
                                      .and_return(double(get_paginated_data: [ [ user2, user3 ], { total: 2 } ]))
      end

      it "returns paginated list of users" do
        get "/api/v1/users?role=user", headers: admin_auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.success.fetched"))
        expect(json["data"].length).to eq(2)
      end
    end

    context 'authorized current users with admin role params' do
      before do
        allow(PaginationService).to receive(:new)
                                      .and_return(double(get_paginated_data: [ [ admin_user ], { total: 1 } ]))
      end

      it "returns paginated list" do
        get "/api/v1/users?role=admin", headers: admin_auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.success.fetched"))
        expect(json["data"].length).to eq(1)
      end
    end
  end

  describe "GET /api/v1/users/:id" do
    context 'authorized user' do
      it "returns serialized user data by admin" do
        get "/api/v1/users/#{user2.id}", headers: admin_auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]).to include("id" => user2.id)
      end

      it "returns serialized user data by self user" do
        get "/api/v1/users/#{user2.id}", headers: user_auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]).to include("id" => user2.id)
      end

      it "does not anything return serialized user data by unknown user" do
        get "/api/v1/users/0", headers: admin_auth_headers

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
      end
    end

    describe 'unauthorized user' do
      it "returns unauthorized error" do
        get "/api/v1/users/#{user3.id}", headers: user_auth_headers

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.errors.unauthorized"))
        expect(json["data"]).to eq(nil)
      end
    end
  end

  describe "PATCH /api/v1/users/:id" do
    it "updates the user successfully by admin user" do
      patch "/api/v1/users/#{user2.id}",
            params: { user: { name: "Updated User" } },
            headers: admin_auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq(I18n.t("api.success.updated"))
      expect(JSON.parse(response.body)["data"]["name"]).to eq("Updated User")
    end

    it "updates the self user successfully" do
      patch "/api/v1/users/#{user2.id}",
            params: { user: { name: "Updated User" } },
            headers: user_auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq(I18n.t("api.success.updated"))
      expect(JSON.parse(response.body)["data"]["name"]).to eq("Updated User")
    end

    it "returns error on invalid update" do
      allow_any_instance_of(User).to receive(:update).and_raise(ActiveRecord::RecordInvalid.new(user2))

      patch "/api/v1/users/#{user2.id}",
            params: { user: { name: "" } },
            headers: user_auth_headers

      expect(response).to have_http_status(:internal_server_error)
    end

    it "could not update other user information" do
      patch "/api/v1/users/#{user3.id}",
            params: { user: { name: "Updated User" } },
            headers: user_auth_headers

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["message"]).to eq(I18n.t("api.errors.unauthorized"))
    end
  end

  describe "DELETE /api/v1/users/:id" do
    context "authorized admin user" do
      let(:deletable_user) { create(:user) }
      it "soft-deletes the user" do
        delete "/api/v1/users/#{deletable_user.id}", headers: admin_auth_headers

        expect(response).to have_http_status(:ok)
        expect(deletable_user.reload.deleted_at).not_to be_nil
      end

      it "returns error if destroy fails" do
        allow_any_instance_of(User).to receive(:update_attribute)
                                         .and_raise(ActiveRecord::RecordNotDestroyed.new("fail"))

        delete "/api/v1/users/#{deletable_user.id}", headers: admin_auth_headers

        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context "deleted authorized admin user" do
      let(:deletable_user) { create(:user) }

      before do
        admin_user.destroy
      end

      it "could not soft-deletes the user" do
        delete "/api/v1/users/#{deletable_user.id}", headers: admin_auth_headers
        expect(response).to have_http_status(:not_found)
        expect(deletable_user.reload.deleted_at).to be_nil
      end
    end
  end

  describe "POST /api/v1/registration" do
    it "creates a new user and stores it in Database" do
      post "/api/v1/registration", params: { user: user_params }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq(I18n.t("api.success.created"))
    end

    it "returns error on invalid user data" do
      post "/api/v1/registration", params: { user: user_params.merge(name: "") }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["message"]).to include("Name can't be blank")
    end
  end
end
