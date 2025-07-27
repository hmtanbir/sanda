require 'rails_helper'

RSpec.describe "Api::V1::UsersController", type: :request do
  include_context "auth_headers"

  let(:user_params) do
    {
      name: "John Doe",
      email: "john@example.com",
      password: "password123",
      role: "user"
    }
  end

  describe "GET /api/v1/users" do
    context 'authorized users' do
      let!(:user1) { create(:user, role: "admin") }
      let!(:user2) { create(:user, role: "user") }

      before do
        allow(PaginationService).to receive(:new)
                                      .and_return(double(get_paginated_data: [[user1, user2], { total: 2 }]))
      end

      it "returns paginated list of users for authorized current users" do
        get "/api/v1/users", headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("data.success.fetched"))
        expect(json["data"].length).to eq(2)
      end
    end

    context 'unauthorized user' do
      let(:unauthorized_user) { create(:user, role: "user") }
      let(:token) { JsonWebToken.encode(user_id: unauthorized_user.id) }
      let(:unauthorized_auth_headers) { { "Authorization" => "Bearer #{token}" } }

      before do
        allow(RedisUserService).to receive(:new).with(unauthorized_user.id).and_return(double(get_user_data: unauthorized_user))
      end

      it "does not return paginated list of users for unauthorized current users" do
        get "/api/v1/users", headers: unauthorized_auth_headers

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.errors.unauthorized"))
      end
    end
  end

  describe "GET /api/v1/users/:id" do
    context 'authorized user' do
      let(:target_user) { create(:user, role: "admin") }

      it "returns serialized user data" do
        get "/api/v1/users/#{target_user.id}", headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"]).to include("id" => target_user.id)
      end
    end

    describe 'unauthorized user' do
      context 'when redis data present' do
        let(:user) { create(:user, role: "user") }
        let(:user2) { create(:user, role: "user") }
        let(:token) { JsonWebToken.encode(user_id: user.id) }
        let(:user_auth_headers) { { "Authorization" => "Bearer #{token}" } }

        before do
          allow(RedisUserService).to receive(:new).with(user.id).and_return(double(get_user_data: user))
        end

        it "returns unauthorized error" do
          get "/api/v1/users/#{user2.id}", headers: user_auth_headers

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq(I18n.t("api.errors.unauthorized"))
          expect(json["data"]).to eq(nil)
        end
      end

      context 'when redis DB data absent' do
        let(:user) { create(:user, role: "user") }
        let(:token) { JsonWebToken.encode(user_id: user.id) }
        let(:user_auth_headers) { { "Authorization" => "Bearer #{token}" } }

        before do
          allow(RedisUserService).to receive(:new)
                                       .with(user.id)
                                       .and_raise(StandardError.new(I18n.t("errors.redis_data_not_found")))
        end

        it "returns unauthorized error" do
          get "/api/v1/users/#{user.id}", headers: user_auth_headers

          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq(I18n.t("errors.redis_data_not_found"))
          expect(json["data"]).to eq(nil)
        end
      end
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
      post "/api/v1/registration", params: { user: user_params.merge(name: "") }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["message"]).to include("Name can't be blank")
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

    before do
      redis_service = instance_double("RedisService")
      allow(RedisUserService).to receive(:new).with(deletable_user).and_return(redis_service)
      allow(redis_service).to receive(:delete)
    end

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
