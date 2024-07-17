class BaseSerializer
	include FastJsonapi::ObjectSerializer

	class << self
		private

		def base_url
			Rails.application.config.x.base_url
		end
	end
end
