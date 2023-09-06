require "csv"
require "openssl"
require "random/secure"

module Secrets
  VERSION = "0.1.0"

  class SecretsHandler
    ALGO = "aes-256-cbc"
    IV_SIZE = 32
    SALT = UInt8.slice(11, 35, 29, 129, 44, 11, 233, 198, 192, 86, 12, 43)

    def initialize(password : String)
      # Create a valid OpenSSL key from password using an HMAC hash (64 bytes)
      @key = OpenSSL::PKCS5.pbkdf2_hmac(password, SALT)
    end

    def encrypt(values : Hash(String, String)) : Nil
      # Make hash a string using CSV
      data =
        CSV.build do |csv|
          values.each do |pair|
            csv.row pair.first, pair.last
          end
        end

      cipher = OpenSSL::Cipher.new(ALGO)
      iv = Random::Secure.random_bytes(IV_SIZE)
      cipher.encrypt
      cipher.key = @key
      cipher.iv = iv

      io = IO::Memory.new
      io.write(cipher.update(data))
      io.write(cipher.final)
      io.rewind

      File.open("secrets.txt", "w") do |f|
        # Write IV
        f.write(iv)
        # Write encrypted data
        f.write(io.to_slice)
      end
    end

    def decrypt() : Hash(String, String)
      cipher = OpenSSL::Cipher.new(ALGO)
      cipher.decrypt
      cipher.key = @key

      io = IO::Memory.new

      File.open("secrets.txt") do |f|
        # Read all bytes from file
        bytes = f.getb_to_end
        # Use the first IV_SIZE bytes as the IV
        cipher.iv = bytes[0...IV_SIZE]
        # Decrypt the rest of the data
        io.write(cipher.update(bytes[IV_SIZE..]))
      end

      io.write(cipher.final)
      io.rewind

      values = Hash(String, String).new

      # CSV parser can read directly from IO object
      CSV.each_row(io) do |row|
        values[row.first] = row.last
      end
      values
    end
  end

  secrets_handler = SecretsHandler.new("secret")
  values = {"Kalle" => "first", "Pelle" => "second"}
  secrets_handler.encrypt values
  puts secrets_handler.decrypt
end