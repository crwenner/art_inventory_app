require 'rqrcode'
require 'fileutils'

class QRService
  def self.generate(id)
    qr_dir = File.expand_path('../../public/qr_codes', __dir__)
    FileUtils.mkdir_p(qr_dir)
    path = File.join(qr_dir, "\#{id}.png")
    qrcode = RQRCode::QRCode.new(id)
    IO.binwrite(path, qrcode.as_png(size: 200).to_s)
    File.join('qr_codes', "\#{id}.png")
  end
end
