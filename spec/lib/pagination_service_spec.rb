require 'rails_helper'

RSpec.describe PaginationService do
  let!(:users) { create_list(:user, 15) }

  let(:pagination_info) { { page: 2, per_page: 5 } }
  let(:service) { described_class.new(User.all, pagination_info, each_serializer: UserSerializer) }

  describe "#get_paginated_data" do
    it "returns paginated and serialized data" do
      paginated_data, meta = service.get_paginated_data

      expect(paginated_data).to be_an(Array)
      expect(paginated_data.size).to eq(5)

      expect(meta[:current_page]).to eq(2)
      expect(meta[:per_page]).to eq(5)
      expect(meta[:total_pages]).to eq(3)
      expect(meta[:total_count]).to eq(15)
      expect(meta[:next_page]).to eq(3)
      expect(meta[:prev_page]).to eq(1)
    end
  end

  describe "#pagination_hash" do
    it "returns correct pagination values" do
      meta = service.pagination_hash

      expect(meta).to eq(
                        current_page: 2,
                        per_page: 5,
                        total_pages: 3,
                        total_count: 15,
                        next_page: 3,
                        prev_page: 1
                      )
    end

    context "when on first page" do
      let(:pagination_info) { { page: 1, per_page: 10 } }

      it "sets prev_page to nil" do
        expect(service.pagination_hash[:prev_page]).to be_nil
      end
    end

    context "when on last page" do
      let(:pagination_info) { { page: 2, per_page: 10 } }

      it "sets next_page to nil" do
        expect(service.pagination_hash[:next_page]).to be_nil
      end
    end
  end
end
