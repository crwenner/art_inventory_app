
require 'rqrcode'
require 'fileutils'

module QRCodeHelpers
  QR_DIR = File.expand_path('../../public/qr_codes', __dir__)

  # Generates a human-readable QR filename like: qr_codes/art_3.png
  def self.generate_qr(data, id)
    FileUtils.mkdir_p(QR_DIR)
    qrcode = RQRCode::QRCode.new(data)

    filename = "art_#{id}.png"
    filepath = File.join(QR_DIR, filename)

    png = qrcode.as_png(size: 200)
    File.open(filepath, 'wb') { |f| f.write(png.to_s) }

    "qr_codes/#{filename}"
  end
end

