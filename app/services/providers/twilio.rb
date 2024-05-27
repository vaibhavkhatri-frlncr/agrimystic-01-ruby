module Providers
  class Twilio
    class << self
      def send_sms(full_phone_number, text_content)
        client = ::Twilio::REST::Client.new(account_id, auth_token)
        client.messages.create(
                                from: ENV['TWILIO_PHONE_NUMBER'],
                                to: full_phone_number,
                                body: text_content
                              )
      end

      def account_id
        Rails.configuration.twilio[:account_sid]
      end

      def auth_token
        Rails.configuration.twilio[:auth_token]
      end

      def from
        Rails.configuration.twilio[:phone_number]
      end
    end
  end
end
