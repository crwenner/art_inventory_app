require 'csv'
require 'fileutils'
require 'securerandom'
require_relative '../lib/helpers/file_helpers'
require_relative '../lib/services/qr_service'

class Inventory
  DATA_DIR = File.expand_path('../data', __dir__)
  FILE_PATH = File.join(DATA_DIR, 'inventory.csv')

  HEADERS = [:id, :name, :image_path, :qr_code, :sold, :sold_where]

  def self.ensure_data_dir
    FileUtils.mkdir_p(DATA_DIR)
  end

  def self.all
    ensure_data_dir
    return [] unless File.exist?(FILE_PATH)
    CSV.read(FILE_PATH, headers: true, header_converters: :symbol).map do |row|
      row.to_h.transform_keys { |k| k.to_sym }.transform_values { |v| v.to_s.strip }
    end
  end

  def self.find(id)
    all.find { |r| r[:id].to_s == id.to_s }
  end

  def self.add(params)
    ensure_data_dir
    id = SecureRandom.uuid
    name = params['name'].to_s.strip
    image_path = FileHelpers.save_image(params['image'])
    qr_path = QRService.generate(id)
    sold = 'false'
    sold_where = ''

    write_headers = !File.exist?(FILE_PATH) || File.zero?(FILE_PATH)
    CSV.open(FILE_PATH, 'a', write_headers: write_headers, headers: HEADERS.map(&:to_s)) do |csv|
      csv << [id, name, image_path, qr_path, sold, sold_where]
    end
  end

  def self.update(id, params)
    items = all
    idx = items.find_index { |i| i[:id].to_s == id.to_s }
    return unless idx
    item = items[idx]

    item[:name] = params['name'].to_s.strip if params['name']
    if params['image'] && params['image'][:tempfile]
      item[:image_path] = FileHelpers.save_image(params['image'])
    end
    item[:sold] = (params['sold'] == 'on' || params['sold'].to_s == 'true') ? 'true' : 'false'
    item[:sold_where] = params['sold_where'].to_s.strip if params['sold_where']

    save_all(items)
  end

  def self.toggle_sold(id, sold_where = '')
    items = all
    idx = items.find_index { |i| i[:id].to_s == id.to_s }
    return unless idx
    item = items[idx]
    new_sold = item[:sold].to_s == 'true' ? 'false' : 'true'
    item[:sold] = new_sold
    item[:sold_where] = new_sold == 'true' ? sold_where.to_s.strip : ''
    save_all(items)
  end

  def self.save_all(items)
    ensure_data_dir
    CSV.open(FILE_PATH, 'w', write_headers: true, headers: HEADERS.map(&:to_s)) do |csv|
      items.each do |i|
        csv << HEADERS.map { |h| i[h] }
      end
    end
  end

  def self.export_csv
    ensure_data_dir
    return '' unless File.exist?(FILE_PATH)
    File.read(FILE_PATH)
  end
end
