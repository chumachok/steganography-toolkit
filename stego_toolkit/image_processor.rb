require "rmagick"

module StegoToolkit
  class ImageProcessor
    class << self

      def embed_data(cover_medium:, output_filename:, data:)
        medium_pixels = cover_medium.export_pixels
        data_pixels = data.export_pixels
        offset = 0

        # embed data
        data_pixels.each do |dp|
          dpb = to_8_bit_binary(dp)
          dpb.each_char do |bit|
            mpb = to_8_bit_binary(medium_pixels[offset])
            mpb[-1] = bit
            medium_pixels[offset] = mpb.to_i(2)
            offset += 1
          end
        end

        medium = cover_medium.import_pixels(0, 0, cover_medium.columns, cover_medium.rows, "RGB", medium_pixels)

        medium
      end

      def extract_data(cover_medium:)
        medium_pixels = cover_medium.export_pixels
        data_pixels = []
        dpb = ""

        medium_pixels.each_with_index do |mp, i|
          mpb = to_8_bit_binary(mp)
          dpb << mpb[-1]
          if ((i + 1) % 8) == 0
            data_pixels << dpb.to_i(2)
            dpb = ""
          end

          break if (i + 1) == (18576 * 8)
        end

        data = Magick::Image.constitute(86, 72, "RGB", data_pixels)
        # data.import_pixels(0, 0, 148, 168, "RGB", data_pixels)

        data
      end

      private

      def to_8_bit_binary(n)
        result = n.to_s(2)
        ("0" * (8 - result.length)) + result
      end

    end
  end
end