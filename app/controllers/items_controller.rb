class ItemsController < ApplicationController

before_action :find_item, only: [:show, :edit,:update,:destroy]



	def index

		if user_signed_in?
			@items = Item.where(:user_id => current_user.id).order("created_at DESC")
			@categories = Category.where(:user_id => current_user.id).order("created_at DESC")
		end
	end


	def new
		if user_signed_in?
			@item = current_user.items.build
		end
	end

	def create
		@item = current_user.items.build(item_params)
		if @item.save
		redirect_to root_path
		else
			render 'new'
		end 

	end

	def edit

	end


	def update
		if @item.update(item_params)
			redirect_to items_path(@item)
		else
			render 'edit'
		end
	end

	def destroy
		@item.destroy
		redirect_to root_path
	end

	def show
		
	end

	def complete
		@item = Item.find(params[:id])
		@item.update_attribute(:completed_at, Time.now)
		redirect_to root_path
	end

private

	def item_params
		params.require(:item).permit(:title,:description,:category)
		
	end

	def find_item
		@item = Item.find(params[:id])
	end


end
