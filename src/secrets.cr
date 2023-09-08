require "option_parser"

require "./handler"

module Secrets
  VERSION = "0.1.0"

  password : String | Nil = nil
  operation : String | Nil = nil
  keys = [] of String
  secret_value : String | Nil = nil

  OptionParser.parse do |parser|
    parser.banner = "Usage: secrets [arguments]"
    #parser.on("-k KEY", "--key=KEY", "Key") { |key| secret_key = key }
    #parser.on("-v VALUE", "--value=VALUE", "Value") { |value| secret_value = value }
    parser.on("get-secrets", "Get a secret") do
      operation = "get-secrets"
      parser.unknown_args do |args|
        keys += args
      end
    end
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end
    parser.on("-p PASSWORD", "--password=PASSWORD", "Password") do |pwd|
      password = pwd
    end
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
    parser.missing_option do |flag|
      STDERR.puts "ERROR: #{flag} is missing."
      STDERR.puts parser
      exit(1)
    end
  end

  pp! password
  pp! operation
  #pp! secret_key
  #pp! secret_value

  if (pwd = password).nil?
    puts "Password required for all operations!"
    exit(1)
  end

  handler = Handler.new(pwd)

  case operation
  when "get-secrets"
    handler.get_secrets(keys).each do |secret|
      puts secret
    end
  else
    raise "Dummy"
  end
end