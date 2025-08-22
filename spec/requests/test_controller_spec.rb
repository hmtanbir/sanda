require 'rails_helper'

RSpec.describe "TestController", type: :request do
  include_context "auth_headers"

  def json_response
    JSON.parse(response.body)
  end

  describe "GET /test" do
    it "returns a successful response with proper JSON" do
      get "/test", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq(200)
      expect(json_response["message"]).to eq("Hello world")
      expect(json_response["data"]).to eq({ "greeting" => "Hello" })
    end
  end

  describe "authentication" do
    it "returns not found if no token is provided" do
      get "/test"
      expect(response).to have_http_status(:not_found)
      expect(json_response["message"]).to eq(I18n.t("api.errors.token.not_found"))
    end

    it "returns unauthorized if token is invalid" do
      allow(JsonWebToken).to receive(:decode).and_return(nil)
      get "/test", headers: { "Authorization" => "Bearer badtoken" }

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["message"]).to eq(I18n.t("api.errors.token.invalid"))
    end
  end

  describe "error handling" do
    it "handles RecordNotFound" do
      get "/test/not_found", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "handles RecordInvalid" do
      get "/test/invalid_record", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "handles StandardError" do
      get "/test/error", headers: auth_headers
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "#pagination_info" do
    let(:controller) { TestController.new }

    it "returns default pagination when params are missing" do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new({}))
      expect(controller.send(:pagination_info)).to eq({ page: 1, per_page: 10 })
    end

    it "returns custom pagination values" do
      params = ActionController::Parameters.new({ page: "3", per_page: "15" })
      allow(controller).to receive(:params).and_return(params)
      expect(controller.send(:pagination_info)).to eq({ page: 3, per_page: 15 })
    end
  end
end
