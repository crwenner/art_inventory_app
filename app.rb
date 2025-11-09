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

# List all art pieces
get '/' do
  @items = read_inventory
  erb :index
end

# Form for new art piece
get '/new' do
  erb :new
end

# Handle creation
post '/new' do
  name = params[:name]
  id = SecureRandom.hex(4)

  # Handle image upload
  image_file = params[:image][:tempfile]
  image_filename = params[:image][:filename]
  save_path = File.join(UPLOAD_DIR, "#{id}_#{image_filename}")
  File.open(save_path, 'wb') { |f| f.write(image_file.read) }

  # Generate QR
  qr = RQRCode::QRCode.new(id)
  qr_path = File.join(QR_DIR, "qr_#{id}.png")
  qr.as_png(size: 200).save(qr_path)

  add_item(id, name, "uploads/#{File.basename(save_path)}", "qr/#{File.basename(qr_path)}")
  redirect '/'
end

# Mark an item as sold
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
    body { font-family: Arial; margin: 40px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ccc; padding: 8px; }
    th { background: #f0f0f0; }
    img { border-radius: 6px; }
  </style>
</head>
<body>
  <%= yield %>
</body>
</html>

@@index
<h1>🎨 Art Inventory</h1>
<a href="/new">➕ Add New</a> | <a href="/export">⬇️ Export CSV</a>
<table>
  <tr><th>ID</th><th>Name</th><th>Image</th><th>QR</th><th>Sold</th><th>Sold Where</th><th>Actions</th></tr>
  <% @items.each do |item| %>
    <tr>
      <td><%= item['id'] %></td>
      <td><%= item['name'] %></td>
      <td><img src="/<%= item['image_path'] %>" width="120"></td>
      <td><img src="/<%= item['qr_code'] %>" width="100"></td>
      <td><%= item['sold'] %></td>
      <td><%= item['sold_where'] %></td>
      <td>
        <% unless item['sold'] == 'true' %>
          <a href="/sold/<%= item['id'] %>">Mark Sold</a>
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

