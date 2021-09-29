require_relative "image"
require_relative "utils"

module StegoToolkit
  class Core
    ACCEPTED_FORMATS = [".bmp"]
    ERROR_MESSAGE_FORMAT = "unsupported file format %s"
    ERROR_MESSAGE_SIZE = "cover medium must contain at least 8 times more bytes than hidden data\n cover medium size: %i bytes\n hidden data size %i"

    def embed(cover_medium:, data_path:, password:)
      # validate!(cover_medium, data_path)
      # data = Magick::ImageList.new(data_path)
      # pixels = data.export_pixels


      
      encrypted_image = Utils.encrypt(cover_medium: cover_medium data: data, password: password)
    end

    def extract(cover_medium:, password:)
      Utils.decrypt(cover_medium: cover_medium, password: password)
    end

    private

    def validate!(cover_medium, data_path)
      ext = File.extname(cover_medium)
      raise StandardError, ERROR_MESSAGE_FORMAT % ext unless ACCEPTED_FORMATS.include?(ext)

      cm_size = File.size(cover_medium)
      hd_size = File.size(data_path)
      raise StandardError, ERROR_MESSAGE_SIZE % [cm_size, hd_size] unless (hd_size * 8) <= cm_size
    end

  end
end