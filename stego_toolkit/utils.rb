require "openssl"

module StegoToolkit
  class Utils
    class << self
      ITERATIONS = 2048
      HASH_LENTH = 24
      CIPHER = "des-ede3"
      DIGEST = OpenSSL::Digest::SHA512.new
      SALT = "\x9Cj\xD2A\x14\t\xDA\x14\x98\xE9\x90<m\x02\xAA`\x9A\xA3_-\xFA\xCB[\xD0Q\xF3^\xF8\xC0\xAB\xED\x82"

      def encrypt(data:, cipher:, password:)
        cipher ||= CIPHER
        cipher = OpenSSL::Cipher.new(cipher).encrypt
        cipher.key = generate_hash(password)

        cipher.update(data) + cipher.final
      end


      def decrypt(data:, cipher:, password:)
        cipher ||= CIPHER
        cipher = OpenSSL::Cipher.new(cipher).decrypt
        cipher.key = generate_hash(password)
        result = cipher.update(data) + cipher.final

        result
      end

      private

      def generate_hash(password)
        OpenSSL::KDF.pbkdf2_hmac(password, salt: SALT, iterations: ITERATIONS, length: HASH_LENTH, hash: DIGEST)
      end

    end
  end
end