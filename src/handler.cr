require "csv"
require "openssl"
require "random/secure"

module Secrets
  class Handler
    ALGO = "aes-256-cbc"
    IV_SIZE = 32
    PATH = "secrets"
    SALT = UInt8.slice(11, 35, 29, 129, 44, 11, 233, 198, 192, 86, 12, 43)

    def initialize(password : String)
      # Create a valid OpenSSL key from password using an HMAC hash (64 bytes)
      @key = OpenSSL::PKCS5.pbkdf2_hmac(password, SALT)
    end

    def get_all_secrets() : Array(Tuple(String, String))
      load_existing_secrets.to_a
    end

    def get_keys() : Array(String)
      load_existing_secrets.keys
    end

    def get_secrets(*keys : String) : Array(Tuple(String, String | Nil))
      get_secrets keys
    end

    def get_secrets(keys : Enumerable(String)) : Array(Tuple(String, String | Nil))
      values = load_existing_secrets
      keys.to_a.map { |key| Tuple(String, String | Nil).new(key, values[key]?) }
    end

    def remove_secrets(*keys : String) : Nil
      remove_secrets keys
    end

    def remove_secrets(keys : Enumerable(String)) : Nil
      values = load_existing_secrets.reject(keys)
      encrypt(values)
    end

    def set_secrets(*pairs : Tuple(String, String)) : Nil
      set_secrets pairs
    end

    def set_secrets(pairs : Enumerable(Tuple(String, String))) : Nil
      # Load existing secrets
      values = load_existing_secrets
      # Update secrets
      pairs.to_a.each { |pair| values[pair.first] = pair.last }
      encrypt(values)
    end

    private def encrypt(values : Hash(String, String)) : Nil
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

      File.open(PATH, "w") do |f|
        # Write IV
        f.write(iv)
        # Write encrypted data
        f.write(io.to_slice)
      end
    end

    private def decrypt() : Hash(String, String)
      cipher = OpenSSL::Cipher.new(ALGO)
      cipher.decrypt
      cipher.key = @key

      io = IO::Memory.new

      File.open(PATH) do |f|
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

    private def load_existing_secrets : Hash(String, String)
      begin
        decrypt
      rescue exception
        Hash(String, String).new
      end
    end
  end
end