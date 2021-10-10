require_relative "image_processor"
require_relative "utils"
require "rmagick"

module StegoToolkit
  class Core
    ACCEPTED_FORMATS = [".bmp", ".png"]
    ERROR_MESSAGE_FORMAT = "unsupported file format %s"
    ERROR_MESSAGE_SIZE = "input data + metadata are too large"
    OUTPUT_DIR_ENCRYPTED = File.join(__dir__, "..", "output", "encrypted")
    OUTPUT_DIR_DECRYPTED = File.join(__dir__, "..", "output", "decrypted")
    SEPARATOR = ":::"

    def embed(cover_medium:, data:, output_filename:, cipher:, password:)
      secret_img = Magick::ImageList.new(data)
      data_pixels = secret_img.export_pixels_to_str

      encrypted_data = Utils.encrypt(data: data_pixels, cipher: cipher, password: password)
      encrypted_filename = Utils.encrypt(data: File.basename(data), cipher: cipher, password: password)
      encrypted_dimensions = Utils.encrypt(data: format_dimensions(secret_img), cipher: cipher, password: password)

      embed_data = to_binary(encrypted_data + SEPARATOR)
      embed_filename = to_binary(encrypted_filename + SEPARATOR)
      embed_dimensions = to_binary(encrypted_dimensions + SEPARATOR)

      validate!(cover_medium, data, embed_data, embed_filename, embed_dimensions)
      new_medium = ImageProcessor.embed_data(
        cover_medium: cover_medium,
        data: embed_data,
        filename: embed_filename,
        dimensions: embed_dimensions,
      )

      ImageProcessor.write_image(path: File.join(OUTPUT_DIR_ENCRYPTED, output_filename), img: new_medium)
    end

    def extract(cover_medium:, cipher:, password:)
      medium_content = ImageProcessor.convert_to_str(cover_medium: cover_medium)
      encrypted_data, encrypted_filename, encrypted_dimensions = medium_content.split(SEPARATOR)

      decrypted_data = Utils.decrypt(data: encrypted_data, cipher: cipher, password: password)
      output_filename = Utils.decrypt(data: encrypted_filename, cipher: cipher, password: password)
      dimensions = Utils.decrypt(data: encrypted_dimensions, cipher: cipher, password: password)

      ImageProcessor.write_secret_image(path: File.join(OUTPUT_DIR_DECRYPTED, output_filename), data: decrypted_data, dimensions: dimensions)
    end

    private

    def to_binary(str)
      str.unpack("B*").first
    end

    def format_dimensions(img)
      "#{img.columns}x#{img.rows}"
    end

    def validate!(cover_medium, secret_img, data, filename, dimensions)
      ext = File.extname(secret_img)
      raise StandardError, ERROR_MESSAGE_FORMAT % ext unless ACCEPTED_FORMATS.include?(ext)

      cm_size = File.size(cover_medium)
      data_size = data.size
      filename_size = filename.size
      dimensions_size = dimensions.size

      raise StandardError, ERROR_MESSAGE_SIZE unless (data_size + filename_size + dimensions_size) <= cm_size
    end

  end
end