require "rmagick"

module StegoToolkit
  class ImageProcessor
    class << self
      DIMENSIONS_SEPARATOR = "x"
      MAP = "RGB"

      def embed_data(cover_medium:, data:, filename:, dimensions:)
        cm = Magick::ImageList.new(cover_medium)
        medium_pixels = cm.export_pixels
        offset = 0

        # embed data
        [data, filename, dimensions].each do |source|
          source.each_char do |bit|
            mpb = to_8_bit_binary(medium_pixels[offset])
            mpb[-1] = bit
            medium_pixels[offset] = mpb.to_i(2)
            offset += 1
          end
        end

        medium = cm.import_pixels(0, 0,cm.columns, cm.rows, MAP, medium_pixels)
        medium
      end

      def convert_to_str(cover_medium:)
        cm = Magick::ImageList.new(cover_medium)
        medium_pixels = cm.export_pixels
        medium_content = ""
        char = ""

        medium_pixels.each_with_index do |mp, i|
          mpb = to_8_bit_binary(mp)
          char << mpb[-1]
          if ((i + 1) % 8) == 0
            medium_content << to_str(char)
            char = ""
          end
        end

        medium_content
      end

      def write_image(path:, img:)
        img.write(path)
      end

      def write_secret_image(path:, data:, dimensions:)
        width, height = dimensions.split(DIMENSIONS_SEPARATOR)
        pixels = data.chars.map { |c| c.ord }
        img = Magick::Image.constitute(width.to_i, height.to_i, MAP, pixels)
        img.write(path)
      end

      private

      def to_8_bit_binary(n)
        result = n.to_s(2)
        ("0" * (8 - result.length)) + result
      end

      def to_str(binary)
        [binary].pack("B*")
      end

    end
  end
end