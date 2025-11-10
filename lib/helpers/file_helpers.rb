require 'securerandom'
require 'fileutils'

module FileHelpers
  UPLOAD_DIR = File.expand_path('../../public/images', __dir__)
  QR_DIR = File.expand_path('../../public/qr_codes', __dir__)

  def self.save_image(image_param)
    return '' unless image_param && image_param[:tempfile] && image_param[:filename] && !image_param[:filename].empty?

    FileUtils.mkdir_p(UPLOAD_DIR)
    filename = "#{SecureRandom.hex(8)}_#{File.basename(image_param[:filename])}"
    path = File.join(UPLOAD_DIR, filename)

    File.open(path, 'wb') { |f| f.write(image_param[:tempfile].read) }

    # Return clean web-accessible path
    "images/#{filename}"
  end
end

