class ApiController < ApplicationController

skip_before_filter  :verify_authenticity_token
before_action :restrict_access, only: [:items]
#curl -H "Content-Type: application/json" -X POST -d '{"log_in": {"email":"admin@admin.pl","password":"adminadmin"}}' http://localhost:3000/api


$current_token

	def login
		
		if @user = User.find_by_email(params[:log_in][:email])
		

			if @user.valid_password?(params[:log_in][:password])
				@key_obj = ApiKey.new("user_id":@user.id)
				
				if @key_obj.save
					render json: {:status => "OK", :token => @key_obj.access_token }
				else
					render json: {:status => "create token error"}
				end

			else
				render json: {:status => "password error"}
			end

		else 
			render json: {:status => "email error"}
		end

	end

	def items
		
		render json: {:status => "OK", :user_id => "#{$current_token.user_id}"}

	end


private


	def restrict_access
	    authenticate_or_request_with_http_token do |token, options|
	      if ApiKey.exists?(access_token: token)
	        
	        $current_token = ApiKey.find_by_access_token(token)

	        
	        if ($current_token.expires_at - Time.now) < 0
	          $current_token.destroy
	          render json: {:message => "token expired error"}
	        else
	          true
	        end

	      else
	        render json: {:message => "invalid token"}
	      end
	    end
	    
	end

end