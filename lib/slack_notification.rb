# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

class SlackNotification
  class << self
    # Sends a Slack notification. Gracefully handles and logs errors.
    # Returns true on success, false on failure/misconfiguration.
    def notify(message, event: :error)
      notify!(message, event: event)
      true
    rescue StandardError => e
      Rails.logger.error "SlackNotification Error: #{e.class} - #{e.message}"
      false
    end

    # Sends a Slack notification. Raises exceptions on failure/misconfiguration.
    def notify!(message, event: :error)
      event_prefix = event.to_s.upcase
      webhook_url = ENV["SLACK_#{event_prefix}_WEBHOOK_URL"].presence || ENV["SLACK_WEBHOOK_URL"].presence
      channel_id = ENV["SLACK_#{event_prefix}_CHANNEL_ID"].presence || ENV["SLACK_CHANNEL_ID"].presence

      if webhook_url.blank?
        raise ArgumentError, "Slack Webhook URL not configured for event: #{event}"
      end

      uri = URI.parse(webhook_url)
      payload = { text: message }
      payload[:channel] = channel_id if channel_id.present?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Post.new(uri.path.empty? ? "/" : uri.path, { "Content-Type" => "application/json" })
      request.body = payload.to_json

      response = http.request(request)

      unless response.code.to_i.between?(200, 299)
        raise "Slack API returned status #{response.code}: #{response.body}"
      end

      response
    end
  end
end
