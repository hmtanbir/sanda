RSpec.shared_context "auth_headers" do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  before do
    allow(RedisUserService).to receive(:new).with(user.id).and_return(double(get_user_data: user))
  end
end
