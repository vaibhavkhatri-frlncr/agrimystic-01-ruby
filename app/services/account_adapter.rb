class AccountAdapter
  include Wisper::Publisher

  def login_account(account_params)
    Rails.logger.info "🔍 Received account_params: #{account_params.inspect}"

    phone = Phonelib.parse(account_params.full_phone_number).sanitized
    Rails.logger.info "📞 Parsed phone: #{phone}"

    account = Account.find_by(full_phone_number: phone, otp_verified: true)

    unless account.present?
      Rails.logger.warn "⚠️ Account not found for phone: #{phone}"
      broadcast(:account_not_found)
      return
    end

    if account.authenticate(account_params.password)
      Rails.logger.info "✅ Password authentication successful for account ID: #{account.id}"
      token, refresh_token = generate_tokens(account.id)
      broadcast(:successful_login, account, token, refresh_token)
    else
      Rails.logger.warn "❌ Password authentication failed for account ID: #{account.id}"
      broadcast(:failed_login)
    end
  end

  def generate_tokens(account_id)
    [
      JsonWebToken.encode(account_id, 1.day.from_now, token_type: 'login'),
      JsonWebToken.encode(account_id, 1.year.from_now, token_type: 'refresh')
    ]
  end
end
