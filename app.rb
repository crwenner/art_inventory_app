require 'sinatra/base'
require 'csv'
require 'securerandom'
require_relative 'models/inventory'
require_relative 'lib/helpers/app_helpers'
require_relative 'lib/helpers/file_helpers'
require_relative 'lib/helpers/qr_code_helpers'

Inventory.initialize_storage

class ArtInventoryApp < Sinatra::Base
  helpers AppHelpers, FileHelpers

  configure do
    set :bind, '0.0.0.0'
    set :port, 4567
    set :root, File.dirname(__FILE__)
    set :public_folder, File.join(settings.root, 'public')
    set :views, File.join(settings.root, 'views')
    set :static, true
  end

  get '/' do
    @items = Inventory.all
    erb :index
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    Inventory.add(params)
    redirect '/'
  end

  get '/items/:id' do
    id = params[:id]
    puts "DEBUG: Looking for item id=#{id.inspect} — Inventory.all.size=#{Inventory.all.size}"
    puts "DEBUG: sample rows: #{Inventory.all.first(5).inspect}"

    @item = Inventory.find(id)

    if @item
      erb :show
    else
      status 404
      "Item not found"
    end
  end

  # Show the edit form for a single item
  get '/items/:id/edit' do
    id = params[:id]
    @item = Inventory.find(id)

    if @item
      erb :edit
    else
      status 404
      "Item not found"
    end
  end

  post '/update/:id' do
    Inventory.update(params[:id], params)
    redirect '/'
  end

  post '/toggle_sold/:id' do
    Inventory.toggle_sold(params[:id], params['sold_where'])
    redirect '/'
  end

  post '/items/:id/delete' do
    id = params[:id]
    Inventory.delete_item(id)
    redirect '/'
  end

  get '/export' do
    content_type 'text/csv'
    attachment 'inventory_export.csv'
    Inventory.export_csv
  end

  run! if app_file == $0
end
