require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:user) { double("User") }
  let(:record) { double("Record") }
  subject(:policy) { described_class.new(user, record) }

  describe "default permission methods" do
    it { expect(policy.index?).to be_falsey }
    it { expect(policy.show?).to be_falsey }
    it { expect(policy.create?).to be_falsey }
    it { expect(policy.new?).to eq(policy.create?) }
    it { expect(policy.update?).to be_falsey }
    it { expect(policy.edit?).to eq(policy.update?) }
    it { expect(policy.destroy?).to be_falsey }
  end

  describe "default error handling flags" do
    it { expect(policy.raise_not_found?).to be_truthy }
    it { expect(policy.raise_invalid_record?).to be_truthy }
    it { expect(policy.raise_standard_error?).to be_truthy }
  end

  describe "Scope" do
    let(:scope_instance) { described_class::Scope.new(user, record) }

    it "raises NoMethodError on resolve" do
      expect {
        scope_instance.resolve
      }.to raise_error(NoMethodError, /You must define #resolve/)
    end
  end
end
