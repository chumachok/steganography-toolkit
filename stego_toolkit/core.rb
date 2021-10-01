require_relative "image_processor"
require_relative "utils"
require "rmagick"

module StegoToolkit
  class Core
    ACCEPTED_FORMATS = [".bmp"]
    ERROR_MESSAGE_FORMAT = "unsupported file format %s"
    ERROR_MESSAGE_SIZE = "input data + metadata are too large"
    OUTPUT_DIR_ENCRYPTED = File.join(__dir__, "..", "output", "encrypted")
    OUTPUT_DIR_DECRYPTED = File.join(__dir__, "..", "output", "decrypted")
    SEPARATOR = ":::"

    def embed(cover_medium:, secret_path:, output_filename:, password:)
      data = Magick::ImageList.new(secret_path)
      data_pixels = data.export_pixels_to_str

      encrypted_data = Utils.encrypt(data: data_pixels, password: password)

      data_binary = to_binary(encrypted_data + SEPARATOR)
      filename_binary = to_binary(File.basename(secret_path) + SEPARATOR)
      dimensions_binary = to_binary(format_dimensions(data) + SEPARATOR)

      validate!(cover_medium, data_binary, filename_binary, dimensions_binary)
      cm = Magick::ImageList.new(cover_medium)
      embeded_data = ImageProcessor.embed_data(
        cover_medium: cm,
        filename_binary: filename_binary,
        dimensions_binary: dimensions_binary,
        data_binary: data_binary
      )

      embeded_data.write(File.join(OUTPUT_DIR_ENCRYPTED, output_filename))
    end

    def extract(cover_medium:, password:)
      cm = Magick::ImageList.new(cover_medium)
      medium = ImageProcessor.convert_to_str(cover_medium: cm)
      encrypted_data, output_filename, dimensions = medium.split(SEPARATOR)

      decrypted_data = Utils.decrypt(data: encrypted_data, password: password)
      ImageProcessor.write_image(path: File.join(OUTPUT_DIR_DECRYPTED, output_filename), data: decrypted_data, dimensions: dimensions)
    end

    private

    def to_binary(str)
      str.unpack("B*").first
    end

    def format_dimensions(img)
      "#{img.columns}x#{img.rows}"
    end

    def validate!(cover_medium, data_binary, filename_binary, dimensions_binary)
      ext = File.extname(cover_medium)
      raise StandardError, ERROR_MESSAGE_FORMAT % ext unless ACCEPTED_FORMATS.include?(ext)

      cm_size = File.size(cover_medium)
      data_size = data_binary.size
      filename_size = filename_binary.size
      dimensions_size = dimensions_binary.size

      raise StandardError, ERROR_MESSAGE_SIZE unless (data_size + filename_size + dimensions_size) <= cm_size
    end

  end
end