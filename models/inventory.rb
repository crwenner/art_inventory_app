require 'csv'
require 'fileutils'

class Inventory
  DATA_DIR  = File.expand_path('../../data', __dir__)
  FILE_PATH = File.join(DATA_DIR, 'inventory.csv')

  HEADERS = %w[id name image qr_code sold sold_where]

  # --- Return all items as an array of hashes ---
  def self.all
    return [] unless File.exist?(FILE_PATH)

    CSV.read(FILE_PATH, headers: true).map do |row|
      {
        id:         row['id'],
        name:       row['name'],
        image:      row['image'],
        qr_code:    row['qr_code'],
        sold:       row['sold'].to_s.downcase,
        sold_where: row['sold_where']
      }
    end
  end

  # --- Generate the next human-friendly numeric ID ---
  def self.next_id
    if File.exist?(FILE_PATH)
      ids = CSV.read(FILE_PATH, headers: true).map { |r| r['id'].to_i }
      ids.empty? ? 1 : ids.max + 1
    else
      1
    end
  end

  # --- Add a new item ---
  def self.add(params)
    FileUtils.mkdir_p(DATA_DIR)

    id   = next_id
    name = params['name']

    # Save uploaded image (if provided)
    image_path = FileHelpers.save_image(params['image'], id)

    # Generate QR code for this item
    qr_code_path = QRCodeHelpers.generate_qr("http://localhost:4567/items/#{id}", id)

    item = {
      id:         id,
      name:       name,
      image:      image_path,
      qr_code:    qr_code_path,
      sold:       'false',
      sold_where: ''
    }

    write_item_to_csv(item)
    item
  end

  # --- Find a single item by ID ---
  def self.find(id)
    all.find { |item| item[:id].to_s == id.to_s }
  end

  # --- Update an item by ID ---
  def self.update(id, params)
    items = all
    item = items.find { |i| i[:id].to_s == id.to_s }
    return unless item

    item[:name]       = params['name'] unless params['name'].to_s.strip.empty?
    item[:sold]       = (params['sold'].to_s == 'on' || params['sold'].to_s == 'true') ? 'true' : 'false'
    item[:sold_where] = params['sold_where'] || ''

    # Replace image if new one uploaded
    if params['image'] && params['image'][:filename] && !params['image'][:filename].empty?
      item[:image] = FileHelpers.save_image(params['image'], id)
    end

    write_all(items)
  end

  # --- Delete an item ---
  def self.delete_item(id)
    items = all.reject { |item| item[:id].to_s == id.to_s }
    write_all(items)
  end

  # --- Toggle sold status ---
  def self.toggle_sold(id, sold_where = '')
    items = all
    item = items.find { |i| i[:id].to_s == id.to_s }
    return unless item

    # flip between 'true' and 'false'
    item[:sold] = (item[:sold] == 'true' ? 'false' : 'true')
    item[:sold_where] = item[:sold] == 'true' ? sold_where : ''
    write_all(items)
  end

  # --- Export CSV content for download ---
  def self.export_csv
    return '' unless File.exist?(FILE_PATH)
    File.read(FILE_PATH)
  end

  private

  # --- Write all items to the CSV file ---
  def self.write_all(items)
    CSV.open(FILE_PATH, 'w', write_headers: true, headers: HEADERS) do |csv|
      items.each { |item| csv << HEADERS.map { |h| item[h.to_sym] } }
    end
  end

  # --- Append a single item to the CSV ---
  def self.write_item_to_csv(item)
    write_headers = !File.exist?(FILE_PATH) || File.zero?(FILE_PATH)
    CSV.open(FILE_PATH, 'a', write_headers: write_headers, headers: HEADERS) do |csv|
      csv << HEADERS.map { |h| item[h.to_sym] }
    end
  end
end
