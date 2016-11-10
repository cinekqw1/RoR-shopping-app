class ApiController < ApplicationController

skip_before_filter  :verify_authenticity_token
before_action :restrict_access, only: [:items, :create_item, :destroy,:complete]



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


	#curl -X POST -H "Authorization: Token token=ed0a992aef6d7a1bedd54163d295ded8" http://localhost:3000/api/items
	def items
		@user = User.find_by_id($current_token.user_id)
		@items = Item.where(:user_id => @user.id).order("created_at DESC")
		render :json => 
  			@items.to_json(:only => [:id, :title, :description, :completed_at])
  			#@items.count
	end

	#curl -H "Content-Type: application/json" -H "Authorization: Token token=ed0a992aef6d7a1bedd54163d295ded8" -X POST -d '{"item": {"title":"Item_1","description":"This is destription of this item. In here may be everything what you want"}}' http://localhost:3000/api/createitem
	def create_item
		@user = User.find_by_id($current_token.user_id)
		
		
		@item = @user.items.build(params.require(:item).permit(:title,:description))
		if @item.save
			render json: {:status => "item created"}
		else
			render json: {:status => "item created error"}
		end 
	end
	
	
	#curl -H "Content-Type: application/json" -H "Authorization: Token token=ed0a992aef6d7a1bedd54163d295ded8" -X POST -d '{"item": {"id":"34"}}' http://localhost:3000/api/complete

	def complete
		@item = Item.find(params[:item][:id])
		if @item.update_attribute(:completed_at, Time.now)
			render json: {:status => "marked succesfull"}
		else
			render json: {:status => "marked error"}
		end
	end

	#curl -H "Content-Type: application/json" -H "Authorization: Token token=ed0a992aef6d7a1bedd54163d295ded8" -X POST -d '{"item": {"id":"34"}}' http://localhost:3000/api/destroy
	def destroy
	
		
		@item = Item.find_by_id(params[:item][:id])
		if @item.nil?
			render json: {:status => "item deleted error"}
			 
		else 
			 @item.destroy
			 render json: {:status => "item deleted"}
		end
	end

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
	          render json: {:status => "token expired error"}
	        else
	          true
	        end

	      else
	        render json: {:status => "invalid token"}
	      end
	    end
	    
	end

end