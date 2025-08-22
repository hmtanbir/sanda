require 'rails_helper'

RSpec.describe "Api::V1::SessionsController", type: :request do
  describe "POST /api/v1/sessions" do
    let(:user) { create(:user, password: "secure123") }
    let(:url) { "/api/v1/sessions" }

    context "with valid credentials" do
      it "returns a valid JWT token" do
        post url, params: {
          user: {
            email: user.email,
            password: "secure123"
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["data"]).to have_key("token")
        expect(json["data"]["token"]).to be_a(String)
      end
    end

    context "with invalid email" do
      it "returns not found with error message" do
        post url, params: {
          user: {
            email: "nonexistent@example.com",
            password: "anything"
          }
        }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.errors.sessions.invalid_email"))
      end
    end

    context "with invalid password" do
      it "returns unauthorized with error message" do
        post url, params: {
          user: {
            email: user.email,
            password: "wrongpassword"
          }
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t("api.errors.sessions.invalid_password"))
      end
    end
  end
end
