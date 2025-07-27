require 'rails_helper'

RSpec.describe "Api::V1::UsersController", type: :request do
  include_context "auth_headers"

  let(:user_params) do
    {
      name: "John Doe",
      email: "john@example.com",
      password: "password123"
    }
  end

  describe "GET /api/v1/users" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    before do
      allow(PaginationService).to receive(:new)
                                    .and_return(double(get_paginated_data: [[user1, user2], { total: 2 }]))
    end

    it "returns paginated list of users" do
      get "/api/v1/users", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq(I18n.t("data.success.fetched"))
      expect(json["data"].length).to eq(2)
    end
  end

  describe "GET /api/v1/users/:id" do
    let(:target_user) { create(:user) }

    it "returns serialized user data" do
      get "/api/v1/users/#{target_user.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).to include("id" => target_user.id)
    end
  end

  describe "POST /api/v1/registration" do
    it "creates a new user and stores it in Redis" do
      allow(RedisUserService).to receive_message_chain(:new, :save)

      post "/api/v1/registration", params: { user: user_params }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq(I18n.t("data.success.created"))
    end

    it "returns error on invalid user data" do
      post "/api/v1/registration", params: { user: user_params.merge(password: "") }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/users/:id" do
    let(:updatable_user) { create(:user, name: "John Doe", email: "john@example.com") }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

    before do
      allow(RedisUserService).to receive(:new).with(updatable_user.id).and_return(double(get_user_data: updatable_user))
    end

    it "updates the user successfully" do
      patch "/api/v1/users/#{updatable_user.id}",
            params: { user: { name: "Updated User" } },
            headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq(I18n.t("data.success.updated"))
      expect(JSON.parse(response.body)["data"]["name"]).to eq("Updated User")
    end

    it "returns error on invalid update" do
      allow_any_instance_of(User).to receive(:update).and_raise(ActiveRecord::RecordInvalid.new(updatable_user))

      patch "/api/v1/users/#{updatable_user.id}",
            params: { user: { name: "" } },
            headers: auth_headers

      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "DELETE /api/v1/users/:id" do
    let(:deletable_user) { create(:user) }

    it "soft-deletes the user" do
      delete "/api/v1/users/#{deletable_user.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(deletable_user.reload.deleted_at).not_to be_nil
    end

    it "returns error if destroy fails" do
      allow_any_instance_of(User).to receive(:update_attribute)
                                       .and_raise(ActiveRecord::RecordNotDestroyed.new("fail"))

      delete "/api/v1/users/#{deletable_user.id}", headers: auth_headers

      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
