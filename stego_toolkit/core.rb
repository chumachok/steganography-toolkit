require_relative "image_processor"
require_relative "utils"
require "rmagick"
require "securerandom"

module StegoToolkit
  class Core
    ACCEPTED_FORMATS = [".bmp"]
    ERROR_MESSAGE_FORMAT = "unsupported file format %s"
    ERROR_MESSAGE_SIZE = "cover medium must contain at least 8 times more bytes than hidden data\n cover medium size: %i bytes\n hidden data size %i"
    OUTPUT_DIR_ENCRYPTED = File.join(__dir__, "..", "output", "encrypted")
    OUTPUT_DIR_DECRYPTED = File.join(__dir__, "..", "output", "decrypted")


    def embed(cover_medium:, data:, output_filename:, password:)
      # validate!(cover_medium, data)
      data = Magick::ImageList.new(data)
      cm = Magick::ImageList.new(cover_medium)
      embeded_data = ImageProcessor.embed_data(cover_medium: cm, output_filename: output_filename, data: data)

      embeded_data.write(File.join(OUTPUT_DIR_ENCRYPTED, output_filename))
      # encrypted_image = Utils.encrypt(cover_medium: cover_medium data: data, password: password)
    end

    def extract(cover_medium:, password:)
      cm = Magick::ImageList.new(cover_medium)
      data = ImageProcessor.extract_data(cover_medium: cm)
      data.write(File.join(OUTPUT_DIR_DECRYPTED, "test.png"))
      # Utils.decrypt(cover_medium: cover_medium, password: password)
    end

    private

    def validate!(cover_medium, data)
      ext = File.extname(cover_medium)
      raise StandardError, ERROR_MESSAGE_FORMAT % ext unless ACCEPTED_FORMATS.include?(ext)

      cm_size = File.size(cover_medium)
      hd_size = File.size(data)
      raise StandardError, ERROR_MESSAGE_SIZE % [cm_size, hd_size] unless (hd_size * 8) <= cm_size
    end

  end
end