class ApiKey < ApplicationRecord

before_create :generate_access_token


private 

	def generate_access_token
		begin
			self.access_token = SecureRandom.hex
		end while self.class.exists?(access_token: access_token)

		self.expires_at = Time.now + 3600 # 3600s is time of session
	end


end