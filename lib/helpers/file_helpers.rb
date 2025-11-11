require 'securerandom'
require 'fileutils'

module FileHelpers
  UPLOAD_DIR = File.expand_path('../../public/images', __dir__)

  # Save uploaded image with a readable name
  # Example: images/art_3_blue_vase.jpg
  def self.save_image(image_param, id = nil)
    return '' unless image_param && image_param[:tempfile] && image_param[:filename] && !image_param[:filename].empty?

    FileUtils.mkdir_p(UPLOAD_DIR)

    # Extract and sanitize the filename
    base_name = File.basename(image_param[:filename], File.extname(image_param[:filename]))
    safe_name = base_name.downcase.gsub(/[^a-z0-9]+/, '_')
    prefix = id ? "art_#{id}" : "art_#{Time.now.to_i}"

    filename = "#{prefix}_#{safe_name}#{File.extname(image_param[:filename])}"
    path = File.join(UPLOAD_DIR, filename)

    File.open(path, 'wb') { |f| f.write(image_param[:tempfile].read) }

    "images/#{filename}"
  end
end

