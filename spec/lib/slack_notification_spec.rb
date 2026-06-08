# frozen_string_literal: true

require "rails_helper"

RSpec.describe SlackNotification do
  let(:general_webhook) { "https://hooks.slack.com/services/fallback/webhook" }
  let(:general_channel) { "C_GENERAL_123" }
  let(:message) { "Hello, Slack!" }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("SLACK_WEBHOOK_URL").and_return(general_webhook)
    allow(ENV).to receive(:[]).with("SLACK_CHANNEL_ID").and_return(general_channel)
    allow(ENV).to receive(:[]).with("SLACK_ERROR_WEBHOOK_URL").and_return(nil)
    allow(ENV).to receive(:[]).with("SLACK_ERROR_CHANNEL_ID").and_return(nil)
    allow(ENV).to receive(:[]).with("SLACK_REGISTRATION_WEBHOOK_URL").and_return(nil)
    allow(ENV).to receive(:[]).with("SLACK_REGISTRATION_CHANNEL_ID").and_return(nil)
  end

  describe ".notify!" do
    context "when event-specific env variables are set" do
      let(:custom_webhook) { "https://hooks.slack.com/services/custom/webhook" }
      let(:custom_channel) { "C_CUSTOM_999" }

      before do
        allow(ENV).to receive(:[]).with("SLACK_REGISTRATION_WEBHOOK_URL").and_return(custom_webhook)
        allow(ENV).to receive(:[]).with("SLACK_REGISTRATION_CHANNEL_ID").and_return(custom_channel)
      end

      it "uses the event-specific webhook and channel" do
        stub_request(:post, custom_webhook)
          .with(body: { text: message, channel: custom_channel }.to_json)
          .to_return(status: 200, body: "ok")

        response = described_class.notify!(message, event: :registration)
        expect(response.code).to eq("200")
        expect(response.body).to eq("ok")
      end
    end

    context "when event-specific env variables are not set" do
      before do
        allow(ENV).to receive(:[]).with("SLACK_SOME_EVENT_WEBHOOK_URL").and_return(nil)
        allow(ENV).to receive(:[]).with("SLACK_SOME_EVENT_CHANNEL_ID").and_return(nil)
      end

      it "falls back to the general webhook and channel" do
        stub_request(:post, general_webhook)
          .with(body: { text: message, channel: general_channel }.to_json)
          .to_return(status: 200, body: "ok")

        response = described_class.notify!(message, event: :some_event)
        expect(response.code).to eq("200")
      end
    end

    context "when no webhook is configured" do
      before do
        allow(ENV).to receive(:[]).with("SLACK_TEST_WEBHOOK_URL").and_return(nil)
        allow(ENV).to receive(:[]).with("SLACK_WEBHOOK_URL").and_return(nil)
      end

      it "raises an ArgumentError" do
        expect {
          described_class.notify!(message, event: :test)
        }.to raise_error(ArgumentError, /Slack Webhook URL not configured/)
      end
    end

    context "when the Slack API returns a failure status" do
      before do
        stub_request(:post, general_webhook).to_return(status: 500, body: "Internal Server Error")
      end

      it "raises a RuntimeError" do
        expect {
          described_class.notify!(message, event: :error)
        }.to raise_error(RuntimeError, /Slack API returned status 500/)
      end
    end
  end

  describe ".notify" do
    context "when a failure occurs" do
      before do
        allow(ENV).to receive(:[]).with("SLACK_ERROR_WEBHOOK_URL").and_return(nil)
        allow(ENV).to receive(:[]).with("SLACK_WEBHOOK_URL").and_return(nil)
      end

      it "rescues the exception, logs it, and returns false" do
        expect(Rails.logger).to receive(:error).with(/SlackNotification Error/)
        result = described_class.notify(message, event: :error)
        expect(result).to be false
      end
    end

    context "when request is successful" do
      before do
        stub_request(:post, general_webhook).to_return(status: 200, body: "ok")
      end

      it "returns true" do
        result = described_class.notify(message, event: :general)
        expect(result).to be true
      end
    end
  end
end
