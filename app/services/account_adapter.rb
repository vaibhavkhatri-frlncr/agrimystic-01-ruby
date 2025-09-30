class AccountAdapter
  include Wisper::Publisher

  def login_account(account_params)
    phone = Phonelib.parse(account_params['full_phone_number']).sanitized
    account = Account.find_by(full_phone_number: phone, otp_verified: true, type: account_params['type'])

    unless account.present?
      broadcast(:account_not_found)
      return
    end

    unless account.activated?
      broadcast(:account_deactivated)
      return
    end

    if account.authenticate(account_params['password'])
      token, refresh_token = generate_tokens(account.id)
      broadcast(:successful_login, account, token, refresh_token)
    else
      broadcast(:failed_login)
    end
  end

  private

  def generate_tokens(account_id)
    [
      JsonWebToken.encode(account_id, 1.day.from_now, token_type: 'login'),
      JsonWebToken.encode(account_id, 1.year.from_now, token_type: 'refresh')
    ]
  end
end
