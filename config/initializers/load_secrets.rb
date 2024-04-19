# Load secrets YAML based on Rails environment
secrets_file = Rails.root.join('config', 'secrets', "#{Rails.env}.yml")

if File.exist?(secrets_file)
  secrets = YAML.load_file(secrets_file)['twilio']
  secrets.each do |key, value|
    ENV[key.upcase] ||= value.to_s
  end
end
