require 'sinatra/base'
require 'csv'
require 'securerandom'
require_relative 'models/inventory'
require_relative 'lib/helpers/app_helpers'
require_relative 'lib/helpers/file_helpers'
require_relative 'lib/services/qr_service'

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
    @show_sold = params['show_sold'] == 'true'
    @search = params['search'].to_s.strip
    @items = Inventory.all

    unless @search.empty?
      q = @search.downcase
      @items = @items.select do |it|
        [it[:name], it[:id], it[:sold_where]].any? { |f| f.to_s.downcase.include?(q) }
      end
    end

    @items = @items.reject { |it| it[:sold].to_s == 'true' } unless @show_sold
    erb :index
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    Inventory.add(params)
    redirect '/'
  end

  get '/edit/:id' do
    @item = Inventory.find(params[:id])
    halt 404, 'Not found' unless @item
    erb :edit
  end

  post '/update/:id' do
    Inventory.update(params[:id], params)
    redirect '/'
  end

  post '/toggle_sold/:id' do
    Inventory.toggle_sold(params[:id], params['sold_where'])
    redirect '/'
  end

  get '/export' do
    content_type 'text/csv'
    attachment 'inventory_export.csv'
    Inventory.export_csv
  end

  run! if app_file == $0
end
