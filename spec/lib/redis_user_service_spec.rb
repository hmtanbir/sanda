require "rails_helper"

RSpec.describe RedisUserService do
  let(:user) { create(:user) }
  let(:redis_key) { "users:#{user.id}" }
  let(:redis_mock) { double("Redis") }

  before do
    allow($redis_user_db).to receive(:set)
    allow($redis_user_db).to receive(:get)
  end

  describe "#save" do
    it "stores serialized user data in Redis" do
      expected_data = {
        id: user.id,
        name: user.email,
        role: user.role,
        created_at: user.created_at,
        updated_at: user.updated_at,
        deleted_at: nil
      }.to_json

      expect($redis_user_db).to receive(:set).with(redis_key, expected_data)

      described_class.new(user).save
    end
  end

  describe "#get_user_data" do
    let(:stored_data) do
      {
        id: user.id,
        name: user.email,
        role: user.role,
        created_at: user.created_at,
        updated_at: user.updated_at,
        deleted_at: nil
      }.to_json
    end

    it "returns parsed user data from Redis" do
      allow($redis_user_db).to receive(:get).with(redis_key).and_return(stored_data)

      result = described_class.new(user.id).get_user_data
      expect(result["id"]).to eq(user.id)
      expect(result["name"]).to eq(user.email)
    end

    it "raises JWT::DecodeError if data is not found" do
      allow($redis_user_db).to receive(:get).with(redis_key).and_return(nil)

      expect {
        described_class.new(user.id).get_user_data
      }.to raise_error(StandardError, I18n.t("errors.redis_data_not_found"))
    end
  end

  describe "#delete" do
    it "returns parsed user data from Redis" do
      allow($redis_user_db).to receive(:get).with(redis_key).and_return(0)

      result = described_class.new(user).delete
      expect(result).to eq(0)
    end
  end
end
