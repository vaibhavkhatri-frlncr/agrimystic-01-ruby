if Rails.env.development? || Rails.env.test?
  require 'dotenv'
  Dotenv.load(Rails.root.join('.env'))
end
