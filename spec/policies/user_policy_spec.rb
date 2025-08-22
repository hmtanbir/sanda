require "rails_helper"

RSpec.describe UserPolicy do
  let(:admin) { instance_double(User, admin?: true, user?: false) }
  let(:regular_user) { instance_double(User, id: 1, admin?: false, user?: true) }
  let(:other_user)   { instance_double(User, id: 2, admin?: false, user?: true) }

  describe "#index?" do
    it "allows admin users" do
      expect(described_class.new(admin, regular_user).index?).to be true
    end

    it "allows regular users" do
      expect(described_class.new(regular_user, regular_user).index?).to be false
    end
  end

  describe "#show?" do
    it "allows admin users" do
      expect(described_class.new(admin, regular_user).show?).to be true
    end

    it "allows a user to view their own record" do
      expect(described_class.new(regular_user, regular_user).show?).to be true
    end

    it "denies access to other users" do
      expect(described_class.new(regular_user, other_user).show?).to be false
    end
  end

  describe "#update?" do
    it "inherits the logic of show?" do
      policy = described_class.new(regular_user, regular_user)
      expect(policy.update?).to eq(policy.show?)
    end
  end

  describe "#destroy?" do
    it "inherits the logic of index?" do
      policy = described_class.new(admin, other_user)
      expect(policy.destroy?).to eq(policy.show?)
    end
  end
end
