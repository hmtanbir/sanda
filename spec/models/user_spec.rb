require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:role) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'password encryption' do
    it 'encrypts the password' do
      user = create(:user, password: 'pass123')
      expect(user.password_digest).to be_present
      expect(user.authenticate('pass123')).to eq(user)
    end
  end

  describe '.all_users scope' do
    it 'returns only users where deleted_at is nil' do
      active_user = create(:user, deleted_at: nil)
      deleted_user = create(:user, deleted_at: Time.current)

      expect(User.all_users).to include(active_user)
      expect(User.all_users).not_to include(deleted_user)
    end
  end

  describe '.role_users scope' do
    it 'returns only admin users where param role is admin' do
      admin_user = create(:user, name: "admin", role: "admin")
      expect(User.role_users(:admin)).to include(admin_user)
    end

    it 'returns only normal users where param role is user' do
      normal_user = create(:user, name: "test user", role: "user")
      expect(User.role_users(:user)).to include(normal_user)
    end
  end
end
