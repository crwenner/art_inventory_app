require 'sinatra'
require 'csv'
require 'rqrcode'
require 'rqrcode_png'
require 'securerandom'
require 'fileutils'

set :bind, '0.0.0.0'
set :port, 4567
set :public_folder, File.dirname(__FILE__) + '/public'

DATA_FILE = 'inventory.csv'
NOTES_DIR = 'notes'
UPLOAD_DIR = File.join(settings.public_folder, 'uploads')
QR_DIR = File.join(settings.public_folder, 'qr')

# Ensure folders exist
[NOTES_DIR, UPLOAD_DIR, QR_DIR].each { |dir| FileUtils.mkdir_p(dir) }

# Ensure CSV file exists
unless File.exist?(DATA_FILE)
  CSV.open(DATA_FILE, 'w') do |csv|
    csv << %w[id name image_path qr_code sold sold_where]
  end
end

def read_inventory
  CSV.read(DATA_FILE, headers: true)
end

def add_item(id, name, image_path, qr_code)
  CSV.open(DATA_FILE, 'a') do |csv|
    csv << [id, name, image_path, qr_code, false, ""]
  end
end

# Home page — list items
get '/' do
  all_items = read_inventory
  @show_sold = params[:show_sold] == 'true'

  @items = if @show_sold
             all_items
           else
             all_items.select { |r| r['sold'] != 'true' }
           end

  erb :index
end

# 🔍 Search functionality
get '/search' do
  query = params[:q].to_s.strip.downcase
  show_sold = params[:show_sold] == 'true'
  all_items = read_inventory

  filtered = if show_sold
               all_items
             else
               all_items.select { |r| r['sold'] != 'true' }
             end

  @items = if query.empty?
             filtered
           else
             filtered.select do |row|
               [row['name'], row['id'], row['sold_where']].any? do |field|
                 field.to_s.downcase.include?(query)
               end
             end
           end

  @search_query = params[:q]
  @show_sold = show_sold
  erb :index
end

# Add new
get '/new' do
  erb :new
end

post '/new' do
  name = params[:name]
  id = SecureRandom.hex(4)

  image_file = params[:image][:tempfile]
  image_filename = params[:image][:filename]
  save_path = File.join(UPLOAD_DIR, "#{id}_#{image_filename}")
  File.open(save_path, 'wb') { |f| f.write(image_file.read) }

  qr = RQRCode::QRCode.new(id)
  qr_path = File.join(QR_DIR, "qr_#{id}.png")
  qr.as_png(size: 200).save(qr_path)

  add_item(id, name, "uploads/#{File.basename(save_path)}", "qr/#{File.basename(qr_path)}")
  redirect '/'
end

# Mark sold
get '/sold/:id' do
  @id = params[:id]
  erb :sold
end

post '/sold/:id' do
  id = params[:id]
  sold_where = params[:sold_where]

  table = read_inventory
  table.each do |row|
    if row['id'] == id
      row['sold'] = true
      row['sold_where'] = sold_where
    end
  end

  CSV.open(DATA_FILE, 'w') do |csv|
    csv << table.headers
    table.each { |row| csv << row }
  end

  File.write("#{NOTES_DIR}/#{id}.txt", "Sold via: #{sold_where} on #{Time.now}")

  redirect '/'
end

# ✏️ Edit item
get '/edit/:id' do
  table = read_inventory
  @item = table.find { |r| r['id'] == params[:id] }
  halt 404, "Item not found" unless @item
  erb :edit
end

post '/edit/:id' do
  id = params[:id]
  name = params[:name]
  sold = params[:sold] == 'on'
  sold_where = params[:sold_where]

  table = read_inventory
  table.each do |row|
    next unless row['id'] == id

    row['name'] = name
    row['sold'] = sold
    row['sold_where'] = sold_where

    if params[:image] && params[:image][:tempfile]
      image_file = params[:image][:tempfile]
      image_filename = params[:image][:filename]
      save_path = File.join(UPLOAD_DIR, "#{id}_#{image_filename}")
      File.open(save_path, 'wb') { |f| f.write(image_file.read) }
      row['image_path'] = "uploads/#{File.basename(save_path)}"
    end
  end

  CSV.open(DATA_FILE, 'w') do |csv|
    csv << table.headers
    table.each { |row| csv << row }
  end

  redirect '/'
end

# Export CSV
get '/export' do
  send_file DATA_FILE, filename: "inventory_export.csv", type: 'application/csv'
end

__END__

@@layout
<!DOCTYPE html>
<html>
<head>
  <title>Art Inventory</title>
  <style>
    body { font-family: Arial; margin: 40px; background: #fafafa; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; background: white; }
    th, td { border: 1px solid #ccc; padding: 8px; }
    th { background: #f0f0f0; }
    img { border-radius: 6px; }
    .sold { color: #888; font-style: italic; background: #f9f9f9; }
    .toggle { margin-top: 10px; }
    a.button { text-decoration: none; background: #007acc; color: white; padding: 5px 10px; border-radius: 4px; }
  </style>
</head>
<body>
  <%= yield %>
</body>
</html>

@@index
<h1>🎨 Art Inventory</h1>

<div class="search-bar">
  <form action="/search" method="get">
    <input type="text" name="q" placeholder="Search by name, ID, or where sold" value="<%= @search_query %>">
    <% if @show_sold %>
      <input type="hidden" name="show_sold" value="true">
    <% end %>
    <button type="submit">Search</button>
    <% if @search_query && !@search_query.empty? %>
      <a href="/">Clear</a>
    <% end %>
  </form>
</div>

<div class="toggle">
  <% if @show_sold %>
    <a href="/">👁️ Hide Sold Items</a>
  <% else %>
    <a href="/?show_sold=true">🖼️ Show Sold Items</a>
  <% end %>
</div>

<br>
<a class="button" href="/new">➕ Add New</a> | <a class="button" href="/export">⬇️ Export CSV</a>

<table>
  <tr><th>ID</th><th>Name</th><th>Image</th><th>QR</th><th>Sold</th><th>Sold Where</th><th>Actions</th></tr>
  <% @items.each do |item| %>
    <tr class="<%= 'sold' if item['sold'] == 'true' %>">
      <td><%= item['id'] %></td>
      <td><%= item['name'] %></td>
      <td><img src="/<%= item['image_path'] %>" width="120"></td>
      <td><img src="/<%= item['qr_code'] %>" width="100"></td>
      <td><%= item['sold'] %></td>
      <td><%= item['sold_where'] %></td>
      <td>
        <a href="/edit/<%= item['id'] %>">✏️ Edit</a>
        <% unless item['sold'] == 'true' %>
          | <a href="/sold/<%= item['id'] %>">Mark Sold</a>
        <% end %>
      </td>
    </tr>
  <% end %>
</table>

@@new
<h1>Add New Art Piece</h1>
<form action="/new" method="post" enctype="multipart/form-data">
  <label>Name:</label><br>
  <input type="text" name="name" required><br><br>

  <label>Image:</label><br>
  <input type="file" name="image" accept="image/*" required><br><br>

  <button type="submit">Add Piece</button>
</form>

@@sold
<h1>Mark as Sold</h1>
<form action="/sold/<%= @id %>" method="post">
  <label>Where was it sold?</label><br>
  <input type="text" name="sold_where" placeholder="Etsy, Local Market..." required><br><br>
  <button type="submit">Save</button>
</form>

@@edit
<h1>Edit Art Piece</h1>
<form action="/edit/<%= @item['id'] %>" method="post" enctype="multipart/form-data">
  <label>Name:</label><br>
  <input type="text" name="name" value="<%= @item['name'] %>" required><br><br>

  <label>Replace Image (optional):</label><br>
  <input type="file" name="image" accept="image/*"><br><br>

  <label>Sold:</label>
  <input type="checkbox" name="sold" <%= 'checked' if @item['sold'] == 'true' %>><br><br>

  <label>Sold Where:</label><br>
  <input type="text" name="sold_where" value="<%= @item['sold_where'] %>" placeholder="Etsy, Market, etc."><br><br>

  <button type="submit">💾 Save Changes</button>
</form>
