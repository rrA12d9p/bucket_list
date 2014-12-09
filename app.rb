require 'sinatra'
require 'sinatra/reloader'
require 'active_record'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
	adapter: 'postgresql',
	host: 'localhost',
	database: 'bucket_db'
)

class Item < ActiveRecord::Base
	has_many :comments
end

class Comment < ActiveRecord::Base
	belongs_to :item
end

get '/' do
	@items = Item.all.order(title: :asc)
	return erb :index
end

get '/item/:itemid' do
	@id = params[:itemid]
	@item = Item.find(@id)
	return "Item not found" if @item == nil

	@title = @item.title
	@description = @item.description
	return erb :item_page
end

post '/item/update/:itemid' do
	@id = params[:itemid]
	@item = Item.find(@id)
	return "Item not found" if @item == nil

	@body = params[:comment]

	if @body.length > 0
		@item.comments.create(body: @body)
	end
	
	@complete = params[:complete_cb]
	
	if @complete == "checked"
		@item.update(complete: true)
	else
		@item.update(complete: false)
	end

	redirect "/item/#{@id}"
end

get '/item/:id/comment/:comment_id/delete' do
	@item_id = params[:id]
	@comment_id = params[:comment_id]
	
	@item = Item.find(@item_id)
	@comment = @item.comments.find(@comment_id)
	
	@comment.destroy

	redirect "/item/#{@item_id}"
end

get '/item/:id/edit/' do
	@item_id = params[:id]
	@item = Item.find(@item_id)

	@title = @item.title
	@description = @item.description

	return erb :rename_item
end

post '/item/:id/edit' do
	@item_id = params[:id]
	@item = Item.find(@item_id)

	@title = params[:title]
	@description = params[:description]

	if @title.length > 0
		new_item = @item.update(title: @title, description: @description)
	end

	redirect '/'
end

get '/item/:id/delete' do
	@item_id = params[:id]
	
	@item = Item.find(@item_id)
	
	@item.destroy

	redirect "/"
end

post '/' do
	@title = params[:title]
	@description = params[:description]

	if @title.length > 0
		new_item = Item.create(title: @title, description: @description, complete: false)
	end
	redirect '/'
end