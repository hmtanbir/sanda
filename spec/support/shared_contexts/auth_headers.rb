RSpec.shared_context "auth_headers" do
  let(:user) { create(:user, role: "admin") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }
end
