class ApiController < ApplicationController

skip_before_filter  :verify_authenticity_token
before_action :restrict_access, only: [:items]



$current_token

#curl -H "Content-Type: application/json" -X POST -d '{"log_in": {"email":"admin@admin.pl","password":"adminadmin"}}' http://localhost:3000/api
	def login
		
		if @user = User.find_by_email(params[:log_in][:email])
		

			if @user.valid_password?(params[:log_in][:password])
				@key_obj = ApiKey.new("user_id":@user.id)
				
				if @key_obj.save
					render json: {:status => "succesfull log in", :token => @key_obj.access_token }
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


	#curl -X POST -H "Authorization: Token token=e6628321336ecbbb91b1819848a10d14" http://localhost:3000/api/items
	def items
		@user = User.find_by_id($current_token.user_id)
		@items = Item.where(:user_id => @user.id).order("created_at DESC")
		render :json => 
  			@items.to_json(:only => [:title, :description])

	end

	#curl -X POST -H "Authorization: Token token=c96044f1bce9a526513a5073d9ea9bcb" http://localhost:3000/api/logout

	def logout

		$current_token.destroy

		render json: {:status => "succesfull log out"}
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